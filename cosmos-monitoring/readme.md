# Monitoring validator node with Grafana and Telegraf
In this guide, we’re going to look at how to Monitor an validator node with Grafana and Telegraf.

Telegraf is an agent written in Go for collecting performance metrics from the system it’s running on and the services running on that system. The collected metrics are output to InfluxDB or other supported data stores. From InfluxDB, you should be able to visualize trends and systems performance using tools like Grafana.

Grafana is an open source, feature rich metrics dashboard and graph editor for Graphite, Elasticsearch, OpenTSDB, Prometheus, and InfluxDB.

![un2](https://user-images.githubusercontent.com/108256873/177758191-b203ea07-6455-4517-b972-ae91c42ab8ff.png)

## 1. Install Telegraf, InfluxDB, Grafana

For installation you can use this [guide](https://github.com/glukosseth/testnet_guide/blob/main/cosmos/usefull_for_cosmos/monitoring/install_guide.md)

## 2. Configure Grafana

### Access Grafana Dashboard

Access Grafana Dashboard using the server IP address or hostname and port `3000`.

![un3](https://user-images.githubusercontent.com/108256873/177762799-43a181c5-23d7-4126-a95a-2cc926c9aab5.png)

Default logins are:
- Usermane: `admin`
- Password: `admin`

### Change Admin Password

Remember to change admin password from default admin. Login and navigate to `Preferences > Change Password`:

![un4](https://user-images.githubusercontent.com/108256873/177764651-46a2025e-ad6a-4b33-87a5-2ad39cefa866.png)

### Add an InfluxDB data source

Before add a dashboard to Grafana for Telegraf system metrics, you need to first import the data source. \
Login to Grafana and go to `Configuration > Data Sources > Add data source > InfluxDB`.

Provide the following details:
- Name – Any valid name
- HTTP URL: InfluxDB URL address e.g http://localhost:8086 for local db server (`<grafana_ip>`)

![un5](https://user-images.githubusercontent.com/108256873/177983992-85dca0c4-efe8-47f4-b44b-982fb4064c25.png)

Under InfluxDB Details, provide:

- Database name as defined on telegraf configuration file (`<database_name>`)
- HTTP authentication username and password as configured on telegraf (`<database_login>`, `<database_password>`)

![un6](https://user-images.githubusercontent.com/108256873/177768295-0ca97901-d7bc-4db9-993e-f8adcd91df5f.png)

### Importing Grafana Dashboard

Once the data source has been added, the next thing is to import the dashboard. I customized one of the dashboards initially created by a user on the community and uploaded it.

Download the dashboard from [here](https://raw.githubusercontent.com/glukosseth/testnet_guide/main/cosmos/usefull_for_cosmos/monitoring/cosmos.json), it is in JSON format. The head over to `Create > Import`:

![un7](https://user-images.githubusercontent.com/108256873/177771367-2c3bf456-fdef-4bf4-a036-b744141b7b4c.png)

Under Options section, give it a unique name and select data source added earlier from the drop-down menu and click the import button.

Set/check your `datasource` and `Server`:

![un8](https://user-images.githubusercontent.com/108256873/177982971-012d96f4-e1f7-4b7e-9984-230434f6ed10.png)

You should see Metrics being visualized immediately.

![un10](https://user-images.githubusercontent.com/108256873/177983134-61ad46ae-2422-49f5-a70a-5beb78bd7a79.png)
