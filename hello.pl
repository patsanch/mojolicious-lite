use Mojolicious::Lite;

get '/' => 'index';

get '/lesson1/' => sub {
	my $self = shift;
  $self->render(text => 'Hello World!');
};

# param is used to get GET and POST parameters
get '/lesson2/:foo' => sub {
  my $self = shift;
  my $foo  = $self->param('foo');
  $self->render(text => "Hello from $foo!");
};

# stash is used to pass data to templates which can be inclined in the DATA section
get '/lesson3/bar' => sub {
  my $self = shift;
  $self->stash(one => 23);
  $self->render('baz', two => 24);
};

get '/lesson4/agent' => sub {
  my $self = shift;
  $self->res->headers->header('X-Bender' => 'Bite my shiny metal ass!');
  $self->render(text => $self->req->headers->user_agent);
};

get '/lesson5/with_layout' => sub {
 	my $self = shift;
	$self->render('with_layout');
};

get '/lesson6/with_block' => 'block';

get '/lesson7/captured' => sub {
  my $self = shift;
  $self->render('captured');
};

# "whois" helper
helper whois => sub {
  my $self  = shift;
  my $agent = $self->req->headers->user_agent || 'Anonymous';
  my $ip    = $self->tx->remote_address;
  return "$agent ($ip)";
};
get '/lesson8/secret' => sub {
  my $self = shift;
  my $user = $self->whois;
  $self->app->log->debug("Request from $user.");
};

# /foo/test
# /foo/test123
get '/lesson9a/foo/:bar' => sub {
  my $self = shift;
  my $bar  = $self->stash('bar');
  $self->render(text => "Our :bar placeholder matched $bar");
};

# /testsomething/foo
# /test123something/foo
get '/lesson9b/(:bar)something/foo' => sub {
  my $self = shift;
  my $bar  = $self->param('bar');
  $self->render(text => "Our :bar placeholder matched $bar");
};

# /hello/test
# /hello/test123
# /hello/test.123/test/123
get '/lesson9c/hello/*you' => 'groovy';

# GET|POST|DELETE /bye
any ['get', 'post', 'delete'] => '/lesson10a/bye' => sub {
  my $self = shift;
  $self->render(text => 'Bye!');
};

# * /baz
any '/lesson10b/baz' => sub {
  my $self   = shift;
  my $method = $self->req->method;
  $self->render(text => "You called /baz with $method");
};

# /hello
# /hello/Sara
get '/lesson11/hello/:name' => {name => 'Sebastian'} => sub {
  my $self = shift;
  $self->render('groovy', format => 'txt');
};

# /test
# /123
any '/lesson12a/:foo' => [foo => ['test', 123]] => sub {
  my $self = shift;
  my $foo  = $self->param('foo');
  $self->render(text => "Our :foo placeholder matched $foo");
};

# /1
# /123
any '/lesson12b/:bar' => [bar => qr/\d+/] => sub {
  my $self = shift;
  my $bar  = $self->param('bar');
  $self->render(text => "Our :bar placeholder matched $bar");
};

# Start the Mojolicious command system
app->start;

__DATA__

@@ index.html.ep
<%= link_to 'Lesson 1: Hello World!' => 'lesson1' %><br/>
<%= link_to 'Lesson 2: Params' => 'lesson2/lettuce' %><br/>
<%= link_to 'Lesson 3: Stash' => 'lesson3/bar' %><br/>
<%= link_to 'Lesson 4: Agent' => 'lesson4/agent' %><br/>
<%= link_to 'Lesson 5: Layouts' => 'lesson5/with_layout' %><br/>
<%= link_to 'Lesson 6: Blocks' => 'lesson6/with_block' %><br/>
<%= link_to 'Lesson 7: Captured' => 'lesson7/captured' %><br/>
<%= link_to 'Lesson 8: Helper' => 'lesson8/secret' %><br/>
<%= link_to 'Lesson 9a: Placeholders' => 'lesson9a/foo/spinach' %><br/>
<%= link_to 'Lesson 9b: Placeholders' => 'lesson9b/(almonds)something/foo' %><br/>
<%= link_to 'Lesson 9c: Placeholders' => 'lesson9c/hello/balsamic/ranch' %><br/>
<%= link_to 'Lesson 10a: HTTP Methods' => 'lesson10a/bye' %><br/>
<%= link_to 'Lesson 10b: HTTP Methods' => 'lesson10b/baz' %><br/>
<%= link_to 'Lesson 11: Optional Placeholders' => 'lesson11/hello/peanutbutter' %><br/>
<%= link_to 'Lesson 12a: Restrictive Placeholders' => 'lesson12a/123' %><br/>
<%= link_to 'Lesson 12b: Restrictive Placeholders' => 'lesson12b/123' %><br/>

@@ baz.html.ep
The magic numbers are <%= $one %> and <%= $two %>.

@@ with_layout.html.ep
% title 'Green!';
% layout 'green';
Hello World!

@@ layouts/green.html.ep
<!doctype html><html>
	<head><title><%= title %></title></head>
  <body><%= content %></body>
</html>

@@ block.html.ep
% my $link = begin
% my ($url, $name) = @_;
Try <%= link_to $url => begin %><%= $name %><% end %>!
% end
<!doctype html><html>
  <head><title>Sebastians frameworks!</title></head>
  <body>
    %= $link->('http://mojolicio.us', 'Mojolicious')
    %= $link->('http://catalystframework.org', 'Catalyst')
  </body>
</html>

@@ captured.html.ep
% layout 'blue', title => 'Green!';
% content_for header => begin
  <meta http-equiv="Pragma" content="no-cache">
% end
Hello World!
% content_for header => begin
  <meta http-equiv="Expires" content="-1">
% end

@@ layouts/blue.html.ep
<!doctype html><html>
  <head>
    <title><%= title %></title>
    %= content_for 'header'
  </head>
  <body><%= content %></body>
</html>

@@ lesson8secret.html.ep
We know who you are <%= whois %>.

@@ groovy.html.ep
Your name is <%= $you %>.

@@ groovy.txt.ep
My name is <%= $name %>.