package Counter::Over::Engineered;
use Moose;
use Bread::Board;

extends 'OX::Application';

augment 'setup_bread_board' => sub {

    service 'template_root' => (
        block => sub {
            (shift)->param('app_root')->subdir(qw[ root templates ])
        },
        dependencies => [ depends_on('app_root') ]
    );

    container 'View' => as {
        service 'TT' => (
            class        => 'OX::View::TT',
            dependencies => [ depends_on('/template_root') ]
        );
    };

    container 'Controller' => as {
        service 'Root' => (
            class        => 'Counter::Over::Engineered::Controller',
            dependencies => {
                view => depends_on('/View/TT')
            }
        );
    };
};

sub router_dependencies {
    +{ root => depends_on('/Controller/Root') }
}

sub configure_router {
    return +{
        '/' => {
            controller => 'root',
            action     => 'index',
        },
        '/inc' => {
            controller => 'root',
            action     => 'inc',
        },
        '/dec' => {
            controller => 'root',
            action     => 'dec',
        },
        '/reset' => {
            controller => 'root',
            action     => 'reset',
        },
    }
}

no Moose; no Bread::Board; 1;

__END__