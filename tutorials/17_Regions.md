# REMIND regions

## Region codes as of REMIND v2.1 and later

csv files with ISO codes can be found as `regionmapping*.csv` in the [`./config`](../config/) folder.

### H12 (hash _62eff8f7_)

| Code | Name | Full list of countries |
|------|------|------------------------|
| CAZ | Canada, NZ, Australia | Canada, Australia, New Zealand, Heard & McDonald Islands, St. Pierre & Miquelon |
| CHA | China | China, Hong Kong, Macau, Taiwan |
| EUR | EU 28 | Aland Islands, Austria, Belgium, Bulgaria, Cyprus, Czechia, Germany, Denmark, Spain, Estonia, Finland, France, Faroe Islands, United Kingdom, Guernsey, Gibraltar, Greece, Croatia, Hungary, Isle of Man, Ireland, Italy, Jersey, Lithuania, Luxembourg, Latvia, Malta, Netherlands, Poland, Portugal, Romania, Slovakia, Slovenia, Sweden |
| IND | India | India |
| JPN | Japan | Japan |
| LAM | Latin America and the Caribbean | Aruba, Anguilla, Argentina, Antarctica, Antigua & Barbuda, Bonaire, Sint Eustatius & Saba, Bahamas, St. Barthélemy, Belize, Bermuda, Bolivia, Brazil, Barbados, Bouvet Island, Chile, Colombia, Costa Rica, Cuba, Curaçao, Cayman Islands, Dominica, Dominican Republic, Ecuador, Falkland Islands, Guadeloupe, Grenada, Guatemala, French Guiana, Guyana, Honduras, Haiti, Jamaica, St. Kitts & Nevis, St. Lucia, St. Martin (French part), Mexico, Montserrat, Martinique, Nicaragua, Panama, Peru, Puerto Rico, Paraguay, South Georgia & South Sandwich Islands, El Salvador, Suriname, Sint Maarten (Dutch part), Turks & Caicos Islands, Trinidad & Tobago, Uruguay, St. Vincent & Grenadines, Venezuela, British Virgin Islands, U.S. Virgin Islands |
| MEA | Middle East, North Africa, Central Asia | United Arab Emirates, Bahrain, Algeria, Egypt, Western Sahara, Iran, Iraq, Israel, Jordan, Kuwait, Lebanon, Libya, Morocco, Oman, Palestinian Territories, Qatar, Saudi Arabia, Sudan, Syria, Tunisia, Yemen |
| NEU | Non-EU28 Europe | Albania, Andorra, Bosnia & Herzegovina, Switzerland, Greenland, Iceland, Liechtenstein, Monaco, North Macedonia, Montenegro, Norway, Svalbard & Jan Mayen, San Marino, Serbia, Turkey, Vatican City |
| OAS | Other Asia | Afghanistan, American Samoa, French Southern Territories, Bangladesh, Brunei, Bhutan, Cocos (Keeling) Islands, Cook Islands, Christmas Island, Fiji, Micronesia (Federated States of), Guam, Indonesia, British Indian Ocean Territory, Cambodia, Kiribati, South Korea, Laos, Sri Lanka, Maldives, Marshall Islands, Myanmar (Burma), Mongolia, Northern Mariana Islands, Malaysia, New Caledonia, Norfolk Island, Niue, Nepal, Nauru, Pakistan, Pitcairn Islands, Philippines, Palau, Papua New Guinea, North Korea, French Polynesia, Singapore, Solomon Islands, Thailand, Tokelau, Timor-Leste, Tonga, Tuvalu, U.S. Minor Outlying Islands, Vietnam, Vanuatu, Wallis & Futuna, Samoa |
| REF | Countries from the Reforming Economies of the Former Soviet Union | Armenia, Azerbaijan, Belarus, Georgia, Kazakhstan, Kyrgyzstan, Moldova, Russia, Tajikistan, Turkmenistan, Ukraine, Uzbekistan |
| SSA | Sub-Saharan Africa | Angola, Benin, Botswana, Burkina Faso, Burundi, Cameroon, Cape Verde, Central African Republic, Chad, Comoros, Congo-Brazzaville, Congo-Kinshasa, Côte d'Ivoire, Djibouti, Equatorial Guinea, Eritrea, Eswatini, Ethiopia, Gabon, Gambia, Ghana, Guinea, Guinea-Bissau, Kenya, Lesotho, Liberia, Madagascar, Malawi, Mali, Mauritania, Mauritius, Mayotte, Mozambique, Namibia, Niger, Nigeria, Réunion, Rwanda, São Tomé & Príncipe, Senegal, Seychelles, Sierra Leone, Somalia, South Africa, South Sudan, St. Helena, Ascension & Tristan da Cunha, Tanzania, Togo, Uganda, Zambia, Zimbabwe |
| USA | USA | USA |

### EU21 (hash _2b1450bc_)

The H21 variant (REMIND-EU) splits the European regions further:

| EU21 region | H12 region | Tentative meaning of name  | Full list of countries |
|-------------|------------|----------------------------|------------------------|
| DEU         | EUR        | Deutschland                | Germany |
| ECE         | EUR        | EU Central East            | Czech Republic, Estonia, Latvia, Lithuania, Poland, Slovakia |
| ECS         | EUR        | EU Central South           | Bulgaria, Croatia, Hungary, Romania, Slovenia |
| ENC         | EUR        | EU North                   | Aland Islands, Denmark, Faroe Islands, Finland, Sweden |
| ESC         | EUR        | EU Southern Center         | Cyprus, Greece, Italy, Malta |
| ESW         | EUR        | EU Southern West           | Portugal, Spain |
| EWN         | EUR        | EU Western North           | Austria, Belgium, Luxembourg, Netherlands |
| FRA         | EUR        | France                     | France |
| UKI         | EUR        | United Kingdom and Ireland | Gibraltar, Guernsey, Ireland, Isle of Man, Jersey, United Kingdom |
| NEN         | NEU        | Non-EU North               | Greenland, Iceland, Liechtenstein, Norway, Svalbard and Jan Mayen, Switzerland |
| NES         | NEU        | Non-EU South               | Albania, Andorra, Bosnia and Herzegovina, Holy See (Vatican City State), North Macedonia, Monaco, Montenegro, San Marino, Serbia, Turkey |

