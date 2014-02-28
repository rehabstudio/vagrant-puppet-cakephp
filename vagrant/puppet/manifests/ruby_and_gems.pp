# install specific ruby version via rbenv
rbenv::install { 'vagrant':
    group => 'vagrant',
    home  => '/home/vagrant',
}

rbenv::compile { $settings::ymlconfig['ruby']['version'] :
    user   => 'vagrant',
    global => true,
}

# # install gems
# rbenv::gem { "sass":
#     user => 'vagrant',
#     ruby => $settings::ymlconfig['env']['ruby'],
# }

# rbenv::gem { "compass":
#     user => 'vagrant',
#     ruby => $settings::ymlconfig['env']['ruby'],
# }
