package in.tapas.forumapp.repository;

import static org.junit.Assert.*;

import java.util.List;

import in.tapas.forumapp.config.ApplicationConfig;
import in.tapas.forumapp.domain.Message;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import org.springframework.test.context.web.WebAppConfiguration;
import org.springframework.transaction.annotation.Transactional;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = ApplicationConfig.class)
@ActiveProfiles("dev")
@Transactional
@WebAppConfiguration
public class MessageRepositoryTest {

	@Autowired
	private MessageRepository messageRepository;
	
	@Test
	public void testFindByMessageAuthor() {
		
		Message message = new Message("test_user", "hello CI");
		
		messageRepository.save(message);
		
		List<Message> messages = messageRepository.findByMessageAuthor("test_user");
		
		assertEquals(1, messages.size());
	}

}