package in.shekhar.forumapp.config;

import javax.sql.DataSource;

import org.apache.commons.dbcp.BasicDataSource;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.orm.jpa.vendor.Database;

@Configuration
@Profile("local")
public class MysqlDataSourceConfig implements DataSourceConfig {

	@Override
	@Bean(destroyMethod = "close")
	public DataSource dataSource() {
		String username = "root";
		String host = "localhost";
		String port = "3306";
		String databaseName = "forumapp";
		String url = "jdbc:mysql://" + host + ":" + port + "/" + databaseName;
		BasicDataSource dataSource = new BasicDataSource();
		dataSource.setDriverClassName("com.mysql.jdbc.Driver");
		dataSource.setUrl(url);
		dataSource.setUsername(username);
		dataSource.setTestOnBorrow(true);
		dataSource.setTestOnReturn(true);
		dataSource.setTestWhileIdle(true);
		dataSource.setTimeBetweenEvictionRunsMillis(1800000);
		dataSource.setNumTestsPerEvictionRun(3);
		dataSource.setMinEvictableIdleTimeMillis(1800000);
		dataSource.setValidationQuery("SELECT version()");

		return dataSource;

	}

	@Override
	public Database database() {
		return Database.MYSQL;
	}

}
