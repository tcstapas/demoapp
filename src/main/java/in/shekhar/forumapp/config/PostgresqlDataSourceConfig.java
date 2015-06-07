package in.shekhar.forumapp.config;

import javax.sql.DataSource;

import org.apache.commons.dbcp.BasicDataSource;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.orm.jpa.vendor.Database;

@Configuration
@Profile("openshift")
public class PostgresqlDataSourceConfig implements DataSourceConfig {

	@Override
	@Bean(destroyMethod = "close")
	public DataSource dataSource() {
		String username = System.getenv("OPENSHIFT_POSTGRESQL_DB_USERNAME");
		String password = System.getenv("OPENSHIFT_POSTGRESQL_DB_PASSWORD");
		String host = System.getenv("OPENSHIFT_POSTGRESQL_DB_HOST");
		String port = System.getenv("OPENSHIFT_POSTGRESQL_DB_PORT");
        String databaseName = System.getenv("OPENSHIFT_APP_NAME");
		String url = "jdbc:postgresql://" + host + ":" + port + "/"+databaseName;
		BasicDataSource dataSource = new BasicDataSource();
		dataSource.setDriverClassName("org.postgresql.Driver");
		dataSource.setUrl(url);
		dataSource.setUsername(username);
		dataSource.setPassword(password);
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
		return Database.POSTGRESQL;
	}

}
