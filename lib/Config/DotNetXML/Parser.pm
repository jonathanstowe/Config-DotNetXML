package Config::DotNetXML::Parser;

use XML::Parser;

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

sub parse
{
   my ( $self, $file ) = @_;

   if ( defined $file )
   {
      $self->File($file);
   }

   $self->data($self->parser->parsefile($self->File()));
}


sub data
{
   my ( $self, $data ) = @_;

   if ( defined $data )
   {
      $self->{_data} = $data;
   }

   return $self->{_data}; 
}

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

1;
