class cpan2rpm{
	exec { 'wget cpan2rpm':
          path    => '/usr/bin',
          command => "wget http://sourceforge.net/projects/cpan2rpm/files/cpan2rpm/2.027/cpan2rpm-2.027-1.noarch.rpm/download",
    	  creates => "/usr/bin/cpan2rpm",
		  require => Exec['groupinstall Base Development tools']
	}

	exec { 'rpm cpan2rpm':
		path	=> '/bin',
		command => "rpm -Uvh cpan2rpm-2.027-1.noarch.rpm",
		require => Exec['wget cpan2rpm'],
		creates => "/usr/bin/cpan2rpm"
	}

	exec { 'rm cpan2rpm':
		path	=> '/bin',
		command => "rm -f cpan2rpm-2.027-1.noarch.rpm",
		require => Exec['rpm cpan2rpm'],
		creates => "/usr/bin/cpan2rpm"
	}
}