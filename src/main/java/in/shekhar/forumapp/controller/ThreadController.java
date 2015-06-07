package in.shekhar.forumapp.controller;

import in.shekhar.forumapp.domain.Thread;
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
@RequestMapping("/threads")
public class ThreadController {

	@Autowired
	private ThreadRepository threadRepository;

	@RequestMapping(method = RequestMethod.POST, produces = MediaType.APPLICATION_JSON_VALUE, consumes = MediaType.APPLICATION_JSON_VALUE)
	@ResponseBody
	public Thread submitNewThread(@RequestBody Thread thread) {
		threadRepository.save(thread);
		return thread;
	}
	
	@RequestMapping(method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
	public @ResponseBody List<Thread> findAllThreads() {
		return threadRepository.findAll();
	}

	@RequestMapping(value = "/{id}", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
	public @ResponseBody Thread findThread(@PathVariable("id") Long id) {
		return threadRepository.findOne(id);
	}
	
	@RequestMapping(value = "/{id}", method = RequestMethod.DELETE)
	public void deleteThread(@PathVariable("id") Long id){
		threadRepository.delete(id);
	}
}
