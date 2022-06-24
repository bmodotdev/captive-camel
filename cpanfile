requires "List::Util";
requires "Params::Validate";
requires "YAML::PP";

on 'develop' => sub {
  recommends 'App::FatPacker::Simple';
};
