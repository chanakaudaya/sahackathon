import ballerina/http;
import ballerina/sql;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;

type StockItem record {
    string itemName;
    string itemDesc;
    string itemImage;
    int includes;
    string intendedFor;
    string color;
    string material;
};

// type StockDetails record {
//     int includes;
//     string intendedFor;
//     string color;
//     string material;
// };

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    # A resource for generating greetings
    # + ID - the input string name
    # + return - StockItem with details or error
    resource function get stockDetails(string ID) returns StockItem[]|error {

        //call database and get the details
        mysql:Client dbClient = check new (host = "sahackathon.mysql.database.azure.com", port = 3306, user = "choreo",
                                          password = "wso2!234", database = "chanaka_db", connectionPool={maxOpenConnections: 3});
        sql:ParameterizedQuery query = `SELECT stock_items.itemName, stock_items.itemDesc, stock_items.itemImage, stock_details.includes, stock_details.intendedFor, stock_details.color, stock_details.material 
                                    FROM stock_items
                                    INNER JOIN stock_details ON stock_items.itemID=stock_details.itemID`;
        stream<StockItem, sql:Error?> resultStream = dbClient->query(query);
        StockItem[] stocks = [];
        int i = 0;

        check from StockItem stock in resultStream
            do {
                stocks[i] = stock;
                i += 1;
            };

        return stocks;
    }
}
