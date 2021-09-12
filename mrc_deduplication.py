import pandas as pd
import pandas_dedupe as dd

deaths = pd.read_excel("data/MatchingtoMEdata.xlsx")

deaths_deduped = dd.dedupe_dataframe(
    deaths,
    ['DECEDENT_FIRST_NAME', 'DECEDENT_LAST_NAME', 'DECEDENT_DOB', 'DEATH_DATE']
)
