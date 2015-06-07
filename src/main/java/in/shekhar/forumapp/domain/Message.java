package in.shekhar.forumapp.domain;

import javax.persistence.Entity;
import javax.persistence.Table;

@Entity
@Table(name = "MESSAGES")
public class Message extends AbstractEntity {
	
	private String author;

	private String text;
	

	public Message() {
	}

	public Message(String author, String text) {
		this.author = author;
		this.text = text;
	}
	
	public void setAuthor(String author) {
		this.author = author;
	}
	public String getAuthor() {
		return author;
	}

	public void setText(String text) {
		this.text = text;
	}

	public String getText() {
		return text;
	}
	

}
