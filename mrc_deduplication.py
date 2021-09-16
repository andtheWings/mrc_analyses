import pandas as pd
import pandas_dedupe as dd
import sqlalchemy as sa
import os

os.chdir('/home/riggins/mrc_analyses/mrc_data')

engine = sa.create_engine("mysql+pymysql://root@127.0.0.1:3306/mrc_data")

people = pd.read_sql(
        '''    
        SELECT * FROM people
        WHERE possible_dupe = 1
        ''', engine)

os.chdir('/home/riggins/mrc_analyses/mrc_data/people_model')

deduped_people = dd.dedupe_dataframe(
        people,
        ['person_id', 'cmrn_id', 'rin_cc']
)

deduped_people.to_parquet('deduped_people')