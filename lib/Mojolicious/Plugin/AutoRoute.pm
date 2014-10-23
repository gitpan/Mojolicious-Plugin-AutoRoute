package Mojolicious::Plugin::AutoRoute;
use Mojo::Base 'Mojolicious::Plugin';

our $VERSION = '0.05';

sub register {
  my ($self, $app, $conf) = @_;
  
  # Renderer
  my $renderer = $app->renderer;
  
  # Parent route
  my $r = $conf->{route} || $app->routes;
  
  # Top directory
  my $top_dir = $conf->{top_dir} || 'auto';
  
  # Index
  $r->route('/')->to(cb => sub { shift->render('/auto/index') });
  
  # Route
  $r->route('/(*anything_path)')->to(cb => sub {
    my $c = shift;
    
    my $path = $c->stash('anything_path');
    $path = 'index' unless defined $path;
    
    if ($path =~ /\.\./) {
      $c->render_exception('Forbidden');
      return;
    }
    
    my $found;
    for my $dir (@{$app->renderer->paths}) {
      if (-f "$dir/$top_dir/$path.html.ep") {
        $found = 1;
        last;
      }
    }
    
    $top_dir =~ s#^/##;
    $top_dir =~ s#/$##;
    if ($found) { $c->render("/$top_dir/$path") }
    else { $c->render_not_found }
  });
}

1;

=head1 NAME

Mojolicious::Plugin::AutoRoute - Mojolicious Plugin to create routes automatically

=head1 CAUTION

B<This is beta release. Implementation will be changed without warnings>. 

=head1 SYNOPSIS

  # Mojolicious
  $self->plugin('AutoRoute');

  # Mojolicious::Lite
  plugin 'AutoRoute';

=head1 DESCRIPTION

L<Mojolicious::Plugin::AutoRoute> is a L<Mojolicious> plugin
to create routes automatically.

Routes corresponding to URL is created .

  TEMPLATES                           ROUTES
  templates/auto/index.html.ep        # /
                /foo.html.ep          # /foo
                /foo/bar.html.ep      # /foo/bar
                /foo/bar/baz.html.ep  # /foo/bar/baz

If you like C<PHP>, this plugin is very good.
You only put file into C<auto> directory.

=head1 OPTIONS

=head2 C<route>

  route => $route;

You can set parent route if you need.
This is L<Mojolicious::Routes> object.
Default is C<$app->routes>.

=head2 C<top_dir>

  top_dir => 'myauto'

Top directory. default is C<auto>.

=head1 METHODS

L<Mojolicious::Plugin::AutoRoute> inherits all methods from
L<Mojolicious::Plugin> and implements the following new ones.

=head2 C<register>

  $plugin->register($app);

Register plugin in L<Mojolicious> application.

=head1 SEE ALSO

L<Mojolicious>, L<Mojolicious::Guides>, L<http://mojolicio.us>.

=cut
