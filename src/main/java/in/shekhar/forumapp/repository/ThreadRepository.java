package in.shekhar.forumapp.repository;

import in.shekhar.forumapp.domain.Message;
import in.shekhar.forumapp.domain.Thread;

import java.util.List;

import org.springframework.data.repository.PagingAndSortingRepository;

public interface ThreadRepository extends PagingAndSortingRepository<Thread, Long> {

	List<Thread> findAll();
	
	List<Thread> findByTagsIn(List<String> tags);

	List<Thread> findByTitleContaining(String title);
	
	List<Thread> findByMessages(Message message);
}
