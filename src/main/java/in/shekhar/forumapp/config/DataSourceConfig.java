package in.shekhar.forumapp.config;

import javax.sql.DataSource;

import org.springframework.orm.jpa.vendor.Database;

public interface DataSourceConfig {
	
	public DataSource dataSource();
	
	public Database database();
	
	
}
