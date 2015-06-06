package in.shekhar.forumapp.controller;

public class MessageVo {

	private String author;

	private String text;
	
	private Long thread;

	public String getAuthor() {
		return author;
	}

	public void setAuthor(String author) {
		this.author = author;
	}

	public String getText() {
		return text;
	}

	public void setText(String text) {
		this.text = text;
	}

	public Long getThread() {
		return thread;
	}

	public void setThread(Long thread) {
		this.thread = thread;
	}
	
	
}
