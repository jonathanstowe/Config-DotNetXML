package Config::DotNetXML::Parser;

use XML::Parser;

our $VERSION;

($VERSION) = q$Revision: 1.2 $ =~ /([\d.]+)/;

=head1 NAME

Config::DotNetXML::Parser - Parse a .NET XML .config file

=head1 SYNOPSIS

use Config::DotNetXML::Parser;

my $parser = Config::DotNetXML::Parser->new(File => $file);

my $config = $parser->data();


=head1 DESCRIPTION

This module implements the parsing for Config::DotNetXML it is designed to
be used by that module but can be used on its own if the import feature is
not required.

THe configuration files are XML documents like:

   <configuration>
      <appSettings>
          <add key="msg" value="Bar" />
      </appSettings>
   </configuration>

and the configuration is returned as a hash reference of the <add /> elements
with the key and value attributes providing respectively the key and value
to the hash.

=head2 METHODS

=over 2

=cut

=item new

Returns a new Config::DotNetXML::Parser object - it takes parameters in
key => value pairs:

=over 2

=item File

The filename containing the configuration.  If this is supplied then the
configuration will be available via the data() method immediately, otherwise
at the minimum parse() will need to be called first.

=back

=cut

sub new
{
   my ( $class, %Args ) = @_;

   my $self = bless {}, $class;

   if ( exists $Args{File} )
   {
      $self->File($Args{File});
   }


   $self->parser(XML::Parser->new(Style => __PACKAGE__));

   if ( defined $self->File() )
   {
      $self->parse();
   }

   return $self;
}

sub parser
{
   my ( $self, $parser ) = @_;

   if ( defined $parser )
   {
      $self->{_parser} = $parser;
   }

   return $self->{_parser};
}

=item parse

This causes the configuration file to be parsed, after which the configuration
will be available via the data() method. It can be supplied with an optional
filename which will remove the need to use the File() method previously.

=cut

sub parse
{
   my ( $self, $file ) = @_;

   if ( defined $file )
   {
      $self->File($file);
   }

   $self->data($self->parser->parsefile($self->File()));
}

=item data

Returns or sets the parsed data - this will be undefined if parse() has not
previously been called.

=cut

sub data
{
   my ( $self, $data ) = @_;

   if ( defined $data )
   {
      $self->{_data} = $data;
   }

   return $self->{_data}; 
}

=item File

Returns or sets the name of the file to be parsed for the configuration.

=cut

=back
=cut

sub File
{
    my ( $self , $file ) = @_;

    if ( defined $file )
    {
       $self->{_file} = $file;
    }

    return $self->{_file};
}

sub Init
{
   my ($expat) = @_;

   $expat->{__PACKAGE__}->{_appsettings}    = {};
   $expat->{__PACKAGE__}->{_in_config}      = 0;
   $expat->{__PACKAGE__}->{_in_appsettings} = 0;
}

sub Final
{
   my ($expat) = @_;

   return $expat->{__PACKAGE__}->{_appsettings};
}

sub Start
{
   my ( $expat, $element, %attr ) = @_;

   $expat->{__PACKAGE__}->{_in_config}++ if $element eq 'configuration';
   $expat->{__PACKAGE__}->{_in_appSettings}++ if $element eq 'appSettings';

   if (  $expat->{__PACKAGE__}->{_in_config} && 
         $expat->{__PACKAGE__}->{_in_appSettings}) 
   {
      if ( $element eq 'add' )
      {
         if ( exists $attr{key} and exists $attr{value} )
         {
             $expat->{__PACKAGE__}->{_appsettings}->{$attr{key}} = $attr{value};
         }
      }
   }
}

sub End
{
   my ( $expat, $element) = @_;

   $expat->{__PACKAGE__}->{_in_config}-- if $element eq 'configuration';
   $expat->{__PACKAGE__}->{_in_appSettings}-- if $element eq 'appSettings';

}


=head1 BUGS

Those familiar with the .NET Framework will realise that this is not a
complete implementation of all of the facilities offered by the 
System.Configuration class: this will come later.

Some may consider the wanton exporting of names into the calling package
to be a bad thing.

=head1 AUTHOR

Jonathan Stowe <jns@gellyfish.com>

=head1 COPYRIGHT

This library is free software - it comes with no warranty whatsoever.

Copyright (c) 2004 Jonathan Stowe

This module can be distributed under the same terms as Perl itself.

=cut

1;

1;
