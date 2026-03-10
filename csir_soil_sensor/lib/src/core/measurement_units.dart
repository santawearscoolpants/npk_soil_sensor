const String salinityDisplayUnit = 'mg/L';
const String tdsDisplayUnit = 'mg/L';

double salinityToMgPerL(num salinity) => salinity.toDouble() * 1000.0;
double tdsToMgPerL(num tds) => tds.toDouble();
