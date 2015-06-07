package in.shekhar.forumapp.controller;

import in.shekhar.forumapp.domain.Message;
import in.shekhar.forumapp.repository.MessageRepository;
import in.shekhar.forumapp.repository.ThreadRepository;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;


@Controller
@RequestMapping("/messages")
public class MessageController {

	@Autowired
	private MessageRepository messageRepository;
	
	@Autowired
	private ThreadRepository threadRepository;

	@RequestMapping(method = RequestMethod.POST, produces = MediaType.APPLICATION_JSON_VALUE, consumes = MediaType.APPLICATION_JSON_VALUE)
	@ResponseBody
	public Message save(@RequestBody MessageVo messageVo) {
		in.shekhar.forumapp.domain.Thread thread = threadRepository.findOne(messageVo.getThread());
		Message message = new Message(messageVo.getAuthor(), messageVo.getText());
		thread.getMessages().add(message);
		threadRepository.save(thread);
		return message;
	}
	
	@RequestMapping(method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
	public @ResponseBody List<Message> findAllMessages() {
		return messageRepository.findAll();
	}

	@RequestMapping(value = "/{id}", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
	public @ResponseBody Message findMessage(@PathVariable("id") Long id) {
		return messageRepository.findOne(id);
	}
	
	@RequestMapping(value = "/{id}", method = RequestMethod.DELETE)
	public void deleteMessage(@PathVariable("id") Long id){
		messageRepository.delete(id);
	}
	
}
