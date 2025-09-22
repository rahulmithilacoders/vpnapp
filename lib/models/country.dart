class Country {
  final String name;
  final String code;
  final String flagEmoji;

  const Country({
    required this.name,
    required this.code,
    required this.flagEmoji,
  });

  static const List<Country> countries = [
    Country(name: 'Albania', code: 'AL', flagEmoji: '🇦🇱'),
    Country(name: 'Argentina', code: 'AR', flagEmoji: '🇦🇷'),
    Country(name: 'Australia', code: 'AU', flagEmoji: '🇦🇺'),
    Country(name: 'Austria', code: 'AT', flagEmoji: '🇦🇹'),
    Country(name: 'Belarus', code: 'BY', flagEmoji: '🇧🇾'),
    Country(name: 'Belgium', code: 'BE', flagEmoji: '🇧🇪'),
    Country(name: 'Bosnia', code: 'BA', flagEmoji: '🇧🇦'),
    Country(name: 'Brazil', code: 'BR', flagEmoji: '🇧🇷'),
    Country(name: 'Bulgaria', code: 'BG', flagEmoji: '🇧🇬'),
    Country(name: 'Canada', code: 'CA', flagEmoji: '🇨🇦'),
    Country(name: 'France', code: 'FR', flagEmoji: '🇫🇷'),
    Country(name: 'Germany', code: 'DE', flagEmoji: '🇩🇪'),
    Country(name: 'India', code: 'IN', flagEmoji: '🇮🇳'),
    Country(name: 'Japan', code: 'JP', flagEmoji: '🇯🇵'),
    Country(name: 'Netherlands', code: 'NL', flagEmoji: '🇳🇱'),
    Country(name: 'Singapore', code: 'SG', flagEmoji: '🇸🇬'),
    Country(name: 'United Kingdom', code: 'GB', flagEmoji: '🇬🇧'),
    Country(name: 'United States', code: 'US', flagEmoji: '🇺🇸'),
  ];
}