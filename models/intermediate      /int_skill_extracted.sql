{{ config(materialized='view', schema='intermediate') }}

with skill_whitelist as (
    select skill, category
    from unnest([
        -- Language
        struct('python' as skill, 'Language' as category),
        struct('sql','Language'),struct('java','Language'),struct('scala','Language'),struct('r','Language'),
        struct('c#','Language'),struct('c++','Language'),struct('golang','Language'),struct('rust','Language'),
        struct('javascript','Language'),struct('typescript','Language'),struct('bash','Language'),
        struct('shell','Language'),struct('matlab','Language'),struct('sas','Language'),
        -- Data Engineering
        struct('spark','Data Engineering'),struct('hadoop','Data Engineering'),struct('hive','Data Engineering'),
        struct('kafka','Data Engineering'),struct('airflow','Data Engineering'),struct('dbt','Data Engineering'),
        struct('prefect','Data Engineering'),struct('luigi','Data Engineering'),struct('flink','Data Engineering'),
        struct('nifi','Data Engineering'),struct('databricks','Data Engineering'),struct('delta lake','Data Engineering'),
        struct('data pipeline','Data Engineering'),struct('etl','Data Engineering'),struct('elt','Data Engineering'),
        -- Cloud
        struct('aws','Cloud'),struct('gcp','Cloud'),struct('azure','Cloud'),struct('google cloud','Cloud'),
        struct('s3','Cloud'),struct('ec2','Cloud'),struct('lambda','Cloud'),
        -- Warehouse
        struct('bigquery','Data Warehouse'),struct('snowflake','Data Warehouse'),struct('redshift','Data Warehouse'),
        struct('data warehouse','Data Warehouse'),struct('data lake','Data Warehouse'),struct('data lakehouse','Data Warehouse'),
        -- Database
        struct('postgresql','Database'),struct('mysql','Database'),struct('sql server','Database'),
        struct('oracle','Database'),struct('mongodb','Database'),struct('redis','Database'),
        struct('elasticsearch','Database'),struct('cassandra','Database'),struct('hbase','Database'),
        struct('pl/sql','Database'),
        -- BI
        struct('tableau','BI'),struct('power bi','BI'),struct('looker','BI'),struct('metabase','BI'),
        struct('superset','BI'),struct('qlik','BI'),struct('grafana','BI'),struct('data studio','BI'),
        -- ML
        struct('machine learning','ML/AI'),struct('deep learning','ML/AI'),struct('tensorflow','ML/AI'),
        struct('pytorch','ML/AI'),struct('scikit-learn','ML/AI'),struct('xgboost','ML/AI'),
        struct('nlp','ML/AI'),struct('computer vision','ML/AI'),struct('mlops','ML/AI'),
        struct('llm','ML/AI'),struct('generative ai','ML/AI'),
        -- Library
        struct('pandas','Library'),struct('numpy','Library'),struct('matplotlib','Library'),
        struct('seaborn','Library'),struct('plotly','Library'),struct('pyspark','Library'),
        struct('fastapi','Library'),
        -- DevOps
        struct('docker','DevOps'),struct('kubernetes','DevOps'),struct('git','DevOps'),
        struct('github','DevOps'),struct('gitlab','DevOps'),struct('ci/cd','DevOps'),
        struct('linux','DevOps'),struct('devops','DevOps'),struct('terraform','DevOps'),
        -- Concept
        struct('data modeling','Concept'),struct('data governance','Concept'),struct('data quality','Concept'),
        struct('data architecture','Concept'),struct('statistics','Concept'),
        -- Tool
        struct('excel','Tool'),struct('jira','Tool'),struct('confluence','Tool')
    ])
),

jobs as (
    select
        job_id,
        -- Kết hợp cả full_text (JD gốc) lẫn title để không bỏ sót bất cứ vị trí nào
        lower(concat(coalesce(title,''), ' ', coalesce(full_text,''))) as search_text, 
        lower(coalesce(tags,'')) as raw_skill_tags
    from {{ ref('int_jobs_deduplicated') }}
),

from_tags as (
    select
        j.job_id,
        w.skill,
        w.category
    from jobs j,
    unnest(split(j.raw_skill_tags, ',')) tag
    join skill_whitelist w
      on trim(tag)=w.skill
),

from_text as (
    select
        j.job_id,
        w.skill,
        w.category
    from jobs j
    cross join skill_whitelist w
    where
    case
        when w.skill='r' then regexp_contains(j.search_text, r'(^|[^a-z0-9])r([^a-z0-9]|$)')
        when w.skill='c++' then regexp_contains(j.search_text, r'(^|[^a-z0-9])c\+\+([^a-z0-9]|$)')
        when w.skill='c#' then regexp_contains(j.search_text, r'(^|[^a-z0-9])c#([^a-z0-9]|$)')
        when w.skill='ci/cd' then regexp_contains(j.search_text, r'(^|[^a-z0-9])ci/cd([^a-z0-9]|$)')
        when w.skill='pl/sql' then regexp_contains(j.search_text, r'(^|[^a-z0-9])pl/sql([^a-z0-9]|$)')
        else regexp_contains(j.search_text, concat(r'(^|[^a-z0-9])', regexp_replace(w.skill, r'([\\.^$|?*+(){}\[\]])', r'\\\1'), r'([^a-z0-9]|$)'))
    end
),

combined as (
    select * from from_tags
    union distinct
    select * from from_text
)

select * from combined