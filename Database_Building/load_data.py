#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Oct 25 13:20:39 2019

@author: joy
"""
# In[]
import pymysql
import numpy as np
import pandas as pd
from sqlalchemy import create_engine

# In[]
# a funtion to connect Python with sql
def connect_mysql():
    print('[Connecting Mysql]...')
    USER = input('user: ')
    PASSWORD = input('pw: ')
    config = {
        'host': '127.0.0.1',
        'port': 3306,
        'user': USER,
        'passwd': PASSWORD,
        'charset':'utf8mb4',
        'cursorclass':pymysql.cursors.DictCursor
        }
    conn = pymysql.connect(**config)
    conn.autocommit(1)
    cursor = conn.cursor()
    engine = create_engine('mysql+pymysql://%s:%s@127.0.0.1:3306/db_consumer_panel' % (USER, PASSWORD))
    return cursor, engine


# In[]
cursor, engine = connect_mysql()

# In[]
import time

def import_tosql(file_name):
    # record time
    x = time.time()

    loop = True
    chunkSize = 900000
    # import data
    df = pd.read_csv(f'../Data/{file_name}.csv')
    # import data to sql
    while loop:
    try:
        chunk = df.get_chunk(chunkSize).drop(columns='Unnamed: 0')
        chunk.to_sql(file_name, engine, index=False, if_exists='replace')
    except StopIteration:
        loop = False
        print ("Iteration is stopped.")
    print("--- %s seconds ---" % (time.time() - x))

# In[]
# import the four datasets into sql
import_tosql('dta_at_hh')
import_tosql('dta_at_prod_id')
import_tosql('dta_at_TC')
import_tosql('dta_at_TC_upc')

