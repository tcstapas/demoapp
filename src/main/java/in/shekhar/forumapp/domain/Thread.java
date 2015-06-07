package in.shekhar.forumapp.domain;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import javax.persistence.CascadeType;
import javax.persistence.CollectionTable;
import javax.persistence.Column;
import javax.persistence.ElementCollection;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.JoinColumn;
import javax.persistence.OneToMany;
import javax.persistence.Table;

@Entity
@Table(name = "THREADS")
public class Thread extends AbstractEntity {

	private String title;
	
	@ElementCollection(fetch = FetchType.EAGER)
	@CollectionTable(name = "TAGS", joinColumns = @JoinColumn(name = "thread_id"))
	@Column(name = "tag")
	private List<String> tags = new ArrayList<String>();

	@OneToMany(cascade = CascadeType.ALL, orphanRemoval = true,fetch=FetchType.EAGER)
	@JoinColumn(name = "thread_id")
	private Set<Message> messages = new HashSet<Message>();
	
	public Thread() {
		// TODO Auto-generated constructor stub
	}
	
	

	public Thread(String title, List<String> tags, Set<Message> messages) {
		super();
		this.title = title;
		this.tags = tags;
		this.messages = messages;
	}



	public void setTitle(String title) {
		this.title = title;
	}

	public String getTitle() {
		return title;
	}

	public void setMessages(Set<Message> messages) {
		this.messages = messages;
	}

	public Set<Message> getMessages() {
		return messages;
	}
	
	public void setTags(List<String> tags) {
		this.tags = tags;
	}
	
	public List<String> getTags() {
		return tags;
	}

}