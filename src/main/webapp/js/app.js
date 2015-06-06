(function($) {

	var ForumApp = {};
	window.ForumApp = ForumApp;
    
        
    ForumApp.Message = Backbone.RelationalModel.extend({
        urlRoot: '/api/messages',
        idAttribute: 'id',
    });

    ForumApp.Thread = Backbone.RelationalModel.extend({
        urlRoot: '/api/threads',
        idAttribute: 'id',
        relations: [{
            type: Backbone.HasMany,
            key: 'messages',
            relatedModel: 'ForumApp.Message',
            reverseRelation: {
                key: 'thread',
                includeInJSON: 'id',
            },
        }]
    });
    
    ForumApp.ThreadCollection = Backbone.Collection.extend({
        url: '/api/threads',
        model: ForumApp.Thread,
    });
    
    
    ForumApp.ThreadListView = Backbone.View.extend({
        tagName: 'div',

        className: 'thread_list_view',
        
        initialize: function(){
            _.bindAll(this, 'render', 'render_thread_summary', 'on_submit', 'on_thread_created', 'on_error');
            this.model.bind('reset', this.render); 
            this.model.bind('change', this.render); 
            this.model.bind('add', this.render_thread_summary); 
        },
    
        template: Handlebars.compile($('#tpl_thread_list').html()),
    
        render: function() {
            $(this.el).html(this.template());
            this.model.forEach(this.render_thread_summary);
            return $(this.el).html();
        },
        
        render_thread_summary: function(thread) {
            var thread_summary_view = new ForumApp.ThreadSummaryView({model: thread});
            this.$('ul.thread_list').prepend($(thread_summary_view.render()));
        },
        
        events: {
            'click .new_thread_submit': 'on_submit',
        },
        
        on_submit: function(e) {
            var thread = new ForumApp.Thread({ title: this.$('.new_thread_title').val() });
            thread.save({}, { success: this.on_thread_created,
                              error: this.on_error });
        },
        
        on_thread_created: function(thread, response) {
            this.model.add(thread, {at: 0});
            var message = new ForumApp.Message({ author: this.$('.new_message_author').val(),
                                                 text: this.$('.new_message_text').val(),
                                                 thread: thread.get('id') });
            message.save({}, { 
                success: function() {
                   	app.navigate('threads/'+thread.get('id')+'/', { trigger: true });
                },
                error: this.on_error,
            });
        },
                
        on_error: function(model, response) {
            var error = $.parseJSON(response.responseText);
            this.$('.error_message').html(error.message);
        },
    });
    
    // Thread //
    
    ForumApp.ThreadSummaryView = Backbone.View.extend({
        tagName: 'li',

        className: 'thread_summary_view',
        
        initialize: function(){
            _.bindAll(this, 'render', 'on_click');
            this.model.bind('change', this.render);
        },
    
        template: Handlebars.compile($('#tpl_thread_summary').html()),
        
        render: function() {
            return $(this.el).html(this.template(this.model.toJSON()));
        },
        
        events: {
            'click': 'on_click',
        },
        
        on_click: function(e) {
            app.navigate('threads/'+this.model.get('id')+'/', {trigger: true});
        },
    });
    
    ForumApp.ThreadView = Backbone.View.extend({
        tagName: 'div',

        className: 'thread_view',
        
        initialize: function(){
            _.bindAll(this, 'render', 'render_message', 'on_submit');
            this.model.bind('change', this.render);
            this.model.bind('reset', this.render);
            this.model.bind('add:messages', this.render_message); 
        },
    
        template: Handlebars.compile($('#tpl_thread').html()),
        
        render: function() {
            return $(this.el).html(this.template(this.model.toJSON()));
        },
        
        render_message: function(message) {
            var message_view = new ForumApp.MessageView({model: message});
            this.$('div.message_list').append($(message_view.render()));
        },
        
        events: {
            'click .new_post_submit': 'on_submit',
        },
        
        on_submit: function(e) {
            var new_message = new ForumApp.Message({author: this.$('.new_message_author').val(),
                                                    text: this.$('.new_message_text').val(),
                                                    thread: this.model});
            new_message.save();
        },
    });
    
    // Message //
    
    ForumApp.MessageView = Backbone.View.extend({
        tagName: 'div',

        className: 'message_view',
        
        initialize: function(){
            _.bindAll(this, 'render');
            this.model.bind('change', this.render);
        },
    
        template: Handlebars.compile($('#tpl_message').html()),
        
        render: function() {
            return $(this.el).html(this.template(this.model.toJSON()));
        },
    });
    
    // Router ///////////////////////////////////////////////////////////////
    
    ForumApp.Router = Backbone.Router.extend({
        routes: {
            "": "show_thread_list",
            "threads/:id/": "show_thread",
        },
    
        show_thread_list: function() {
        	console.log('in show_thread_list() ... ');
            var thread_collection = new ForumApp.ThreadCollection();
            var thread_list_view = new ForumApp.ThreadListView({el: $('#content'), 
                                                                model: thread_collection });
            thread_collection.fetch();
        },
        
        show_thread: function(id) {
            var thread = new ForumApp.Thread({id: id});
            var thread_view = new ForumApp.ThreadView({el: $('#content'), model: thread});
            thread.fetch();
        },
        
    });
    
    
    
    var app = new ForumApp.Router(); 
    Backbone.history.start();

})(jQuery);

