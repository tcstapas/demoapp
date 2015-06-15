package in.tapas.forumapp.repository;

import java.util.List;

import in.tapas.forumapp.domain.Message;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.CrudRepository;
import org.springframework.transaction.annotation.Transactional;

public interface MessageRepository extends CrudRepository<Message, Long> {

	@Transactional(timeout = 10)
	<S extends Message> S save(S entity);

	public List<Message> findAll();
	
	@Query("select m from Message m where m.author=?1")
	public List<Message> findByMessageAuthor(String author);

}
