use Mojo::Base -strict;

use Test::More tests => 9;
use Test::Mojo;

my $t = Test::Mojo->new('TreeManager');
$t->get_ok('/login')->status_is(200)->content_like(qr/login-form-wrapper/i);
$t->get_ok('/tree')->status_is(200)->content_like(qr/workbook-item-article-list-header/i);
$t->get_ok('/logout')->status_is(200)->content_like(qr/notfound/i);
