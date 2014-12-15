use 5.014001;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Sim::OPT',
    VERSION_FROM      => 'lib/Sim/OPT.pm', # finds $VERSION
    PREREQ_PM         => {
			'List::MoreUtils' => '0.01',
			'Math::Round'	=> '0',
			'Math::Trig'  => '0',
			'List::Util' => '0',
			'List::AllUtils' => '0',
			'Statistics::Basic'  => '0',
			'IO::Tee'  => '0',
			'Set::Intersection'  => '0',
			'List::Compare'  => '0',
			'File::Tee'  => '0',
			
			}, # e.g., Module::Name => 1.1
    ($] >= 5.014 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT       => 'Sim::OPT it a tool for detailed metadesign managing parametric explorations through the ESP-r building performance simulation platform and performing optimization by block coordinate descent.', # retrieve abstract from module
       AUTHOR         => 'Gian Luca Brunetti <gianluca.brunetti@polimi.it>') : ()),
);

