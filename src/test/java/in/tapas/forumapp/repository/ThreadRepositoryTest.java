package in.tapas.forumapp.repository;

import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.notNullValue;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertThat;
import static org.junit.Assert.assertTrue;
import in.tapas.forumapp.config.ApplicationConfig;
import in.tapas.forumapp.domain.Message;
import in.tapas.forumapp.domain.Thread;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
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
public class ThreadRepositoryTest {

	@Autowired
	private ThreadRepository threadRepository;

	@Test
	public void shouldSaveThread() {
		in.tapas.forumapp.domain.Thread thread = newThread();

		threadRepository.save(thread);
		assertNotNull(thread);
		assertNotNull(thread.getId());
	}

	@Test
	public void shouldFindOneThread() {
		in.tapas.forumapp.domain.Thread thread = newThread();
		threadRepository.save(thread);

		in.tapas.forumapp.domain.Thread findOne = threadRepository.findOne(thread.getId());
		assertNotNull(findOne);
	}

	@Test
	public void testExists() {
		in.tapas.forumapp.domain.Thread thread = newThread();
		threadRepository.save(thread);

		boolean exists = threadRepository.exists(thread.getId());
		assertTrue(exists);
	}

	@Test
	public void testCount() {
		in.tapas.forumapp.domain.Thread thread = newThread();
		threadRepository.save(thread);

		long count = threadRepository.count();

		assertEquals(1, count);
	}

	@Test
	public void testDelete() {
		in.tapas.forumapp.domain.Thread thread = newThread();
		threadRepository.save(thread);

		threadRepository.delete(thread);

		in.tapas.forumapp.domain.Thread findOne = threadRepository.findOne(thread.getId());
		assertNull(findOne);
	}

	@Test
	public void testFindAll() {
		in.tapas.forumapp.domain.Thread thread = newThread();
		threadRepository.save(thread);

		List<in.tapas.forumapp.domain.Thread> recipes = threadRepository.findAll();
		assertEquals(1, recipes.size());
	}

	@Test
	public void testFindByMessage() {
		in.tapas.forumapp.domain.Thread thread = newThread();
		threadRepository.save(thread);

		List<Thread> threads = threadRepository.findByMessages(thread.getMessages().iterator().next());

		assertEquals(1, threads.size());
	}

	@Test
	public void testFindByTagsIn() {
		in.tapas.forumapp.domain.Thread thread = newThread();
		threadRepository.save(thread);

		List<in.tapas.forumapp.domain.Thread> threads = threadRepository.findByTagsIn(Arrays.asList("test"));

		assertEquals(1, threads.size());
	}

	@Test
	public void accessThreadsPageByPage() {
		List<in.tapas.forumapp.domain.Thread> threads = newThreads(10);
		threadRepository.save(threads);

		Page<in.tapas.forumapp.domain.Thread> result = threadRepository.findAll(new PageRequest(1, 1));

		assertThat(result, is(notNullValue()));

		assertThat(result.isFirstPage(), is(false));
		assertThat(result.isLastPage(), is(false));
		assertThat(result.getNumberOfElements(), is(1));
	}
	

	private in.tapas.forumapp.domain.Thread newThread() {
		Set<Message> messages = new HashSet<Message>();
		messages.add(new Message("test user", "test message"));
		messages.add(new Message("another test user", "another test message"));
		return new in.tapas.forumapp.domain.Thread("test topic",Arrays.asList("test","test123"),messages);
	}

	private List<in.tapas.forumapp.domain.Thread> newThreads(int count) {
		List<in.tapas.forumapp.domain.Thread> threads = new ArrayList<in.tapas.forumapp.domain.Thread>();

		for (int i = 0; i < count; i++) {
			Set<Message> messages = new HashSet<Message>();
			messages.add(new Message("test user", "test message"));
			messages.add(new Message("another test user", "another test message"));
			Thread thread = new in.tapas.forumapp.domain.Thread("test topic",Arrays.asList("test","test123"),messages);
			threads.add(thread);
		}

		return threads;
	}

}
