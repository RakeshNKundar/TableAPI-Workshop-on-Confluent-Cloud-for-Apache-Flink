package org.example;

import io.confluent.flink.plugin.*;

import org.apache.flink.table.api.*;

import java.util.*;

import static org.apache.flink.table.api.DataTypes.*;
import static org.apache.flink.table.api.Expressions.*;

public class Main {
    public static void main(String[] args) {
        // Fill this with the Environment name on your Confluent Cloud
        final String TARGET_CATALOG = "CC_Flink_TableAPI_Workshop";

        // Fill this with a Kafka cluster you have write access to
        final String TARGET_DATABASE = "Table_API_Workshop_Kafka_Cluster";

        EnvironmentSettings settings = ConfluentSettings.fromResource("/ccloud.properties");
        TableEnvironment env = TableEnvironment.create(settings);

        //        env.executeSql("SHOW CATALOGS").print();
        //        env.executeSql("SHOW DATABASES").print();

        // Set default catalog and database
        env.useCatalog(TARGET_CATALOG);
        env.useDatabase(TARGET_DATABASE);

        String[] tables = env.listTables();
        List<String> tableList = Arrays.asList(tables);

        Schema ordersFilteredTableSchema =
                Schema.newBuilder()
                        .column("product_id", DataTypes.STRING().notNull())
                        .column("order_id", DataTypes.STRING().notNull())
                        .column("customer_id", DataTypes.INT().notNull())
                        .column("price", DataTypes.DOUBLE().notNull())
                        .build();

        TableDescriptor ordersFileterdTableDescriptor =
                TableDescriptor.forConnector("confluent")
                        .schema(ordersFilteredTableSchema)
                        .option("value.format", "avro-registry")
                        .option("kafka.retention.time", "7 days")
                        .option("scan.startup.mode", "earliest-offset")
                        .distributedBy(3, "product_id")
                        .build();

        String ordersFilteredTableName = "orders_filtered";

        if (!tableList.contains(ordersFilteredTableName)) {
            env.createTable(ordersFilteredTableName, ordersFileterdTableDescriptor);
        }

        String filteredStatementName = "orders-filtered-insert-v1" + UUID.randomUUID();
        env.getConfig().set("client.statement-name", filteredStatementName);

        TableResult ordersFileterdTable =
                env.from("examples.marketplace.orders")
                        .where($("customer_id").between(3000, 4000))
                        .select($("product_id"), $("order_id"), $("customer_id"), $("price"))
                        .insertInto("orders_filtered")
                        .execute();

        Schema ordersWindowedCountTableSchema =
                Schema.newBuilder()
                        .column("product_id", DataTypes.STRING().notNull())
                        .column("window_start", DataTypes.TIMESTAMP(3).notNull())
                        .column("window_end", DataTypes.TIMESTAMP(3).notNull())
                        .column("total_sale", DataTypes.DOUBLE().notNull())
                        .build();

        TableDescriptor ordersWindowedCountTableDescriptor =
                ConfluentTableDescriptor.forManaged()
                        .schema(ordersWindowedCountTableSchema)
                        .option("value.format", "avro-registry")
                        .option("kafka.retention.time", "7 days")
                        .option("scan.startup.mode", "earliest-offset")
                        .distributedBy(3, "product_id")
                        .build();

        String ordersWindowedAggregationTableName = "orders_windowed_aggregation";

        if (!tableList.contains(ordersWindowedAggregationTableName)) {
            env.createTable(ordersWindowedAggregationTableName, ordersWindowedCountTableDescriptor);
        }

        String windowedAggregationStatementName =
                "orders-windowed-aggregation-insert-v1" + UUID.randomUUID();
        env.getConfig().set("client.statement-name", windowedAggregationStatementName);

        TableResult ordersWindowedCountTable =
                env.from("examples.marketplace.orders")
                        .window(Tumble.over(lit(1).minutes()).on($("$rowtime")).as("w"))
                        .groupBy($("w"), $("product_id"))
                        .select(
                                $("product_id"),
                                $("w").start().as("window_start"),
                                $("w").end().as("window_end"),
                                $("price").sum().round(2).as("total_units"))
                        .insertInto(ordersWindowedAggregationTableName)
                        .execute();

        //        ordersWindowedCountTable.collect().forEachRemaining(System.out::println);

        Schema ordersProductEnrichedTableSchema =
                Schema.newBuilder()
                        .column("product_id", DataTypes.STRING().notNull())
                        .column("order_id", DataTypes.STRING().notNull())
                        .column("customer_id", DataTypes.INT().notNull())
                        .column("product_name", DataTypes.STRING())
                        .column("product_brand", DataTypes.STRING())
                        .column("product_vendor", DataTypes.STRING())
                        .column("price", DataTypes.DOUBLE().notNull())
                        .build();

        TableDescriptor ordersProductEnrichedTableDescriptor =
                TableDescriptor.forConnector("confluent")
                        .schema(ordersProductEnrichedTableSchema)
                        .option("value.format", "avro-registry")
                        .option("kafka.retention.time", "7 days")
                        .option("scan.startup.mode", "earliest-offset")
                        .distributedBy(3, "product_id")
                        .build();

        String ordersProductEnrichedTableName = "orders_product_enriched";

        if (!tableList.contains(ordersProductEnrichedTableName)) {
            env.createTable(ordersProductEnrichedTableName, ordersProductEnrichedTableDescriptor);
        }

        String productsEnrichmentStatementName =
                "orders-product-enrichment-insert-v1" + UUID.randomUUID();
        env.getConfig().set("client.statement-name", productsEnrichmentStatementName);

        TableResult ordersProductEnrichedTable =
                env.executeSql(
                        """
                                INSERT INTO orders_product_enriched
                                SELECT
                                    o.product_id,
                                    o.order_id,
                                    o.customer_id,
                                    p.name as product_name,
                                    p.brand as product_brand,
                                    p.vendor as product_vendor,
                                    o.price
                                FROM `examples`.`marketplace`.`orders` AS o
                                LEFT JOIN `examples`.`marketplace`.`products`
                                FOR SYSTEM_TIME AS OF o.`$rowtime` AS p
                                ON o.product_id = p.product_id;
                                """);
    }
}
