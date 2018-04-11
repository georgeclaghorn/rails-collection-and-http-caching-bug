[rails/rails#31250](https://github.com/rails/rails/pull/31250) broke collection caching in controller actions using HTTP caching.

`PostsController#index` passes a relation to `fresh_when` for the purpose of setting the `ETag` header:

```ruby
class PostsController < ApplicationController
  def index
    @posts = Post.all
    fresh_when @posts
  end
end
```

The corresponding view (`app/views/posts/index.html.erb`) renders the same relation object as a cached collection:

```ruby
<%= render partial: 'posts/post', collection: @posts, cached: true %>
```

When the `posts#index` action is invoked, an `ActiveRecord::ImmutableRelation` error is raised.

`ActiveRecord::Railties::CollectionCacheAssociationLoading#relation_from_options` checks whether the relation it chooses is loaded before calling `ActiveRecord::Relation::QueryMethods#skip_preloading!`, but that method can raise an `ActiveRecord::ImmutableRelation` error even if the relation isn't loaded (i.e. when `ActiveRecord::Relation::QueryMethods#arel` was previously called).
