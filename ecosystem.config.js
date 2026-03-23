module.exports = {
  apps: [
    {
      name: "config-server",
      script: "java -jar platform/config-server/target/config-server-1.0.0.jar",
      log_file: "./logs/config-server.log"
    },
    {
      name: "service-registry",
      script: "java -jar platform/service-registry/target/service-registry-1.0.0.jar",
      log_file: "./logs/service-registry.log"
    },
    {
      name: "api-gateway",
      script: "java -jar platform/api-gateway/target/api-gateway-1.0.0.jar",
      log_file: "./logs/api-gateway.log"
    },
    {
      name: "user-service",
      script: "java -jar services/user-service/target/user-service-1.0.0.jar",
      log_file: "./logs/user-service.log",
      instances: 2
    },
    {
      name: "menu-service",
      script: "java -jar services/menu-service/target/menu-service-1.0.0.jar",
      log_file: "./logs/menu-service.log",
      instances: 2
    },
    {
      name: "order-service",
      script: "java -jar services/order-service/target/order-service-1.0.0.jar",
      log_file: "./logs/order-service.log",
      instances: 2
    },
    {
      name: "kitchen-service",
      script: "java -jar services/kitchen-service/target/kitchen-service-1.0.0.jar",
      log_file: "./logs/kitchen-service.log",
      instances: 2
    }
  ]
};
