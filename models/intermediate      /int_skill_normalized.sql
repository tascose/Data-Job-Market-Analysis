{{ config(materialized='view', schema='intermediate') }}

with base as (
    select * from {{ ref('int_skill_extracted') }}
),

normalized as (
    select
        job_id,
        category,
        case
            when skill in ('google cloud', 'gcp') then 'gcp'
            when skill in ('postgres', 'postgresql') then 'postgresql'
            when skill in ('mssql', 'sql server', 'ms sql') then 'sql server'
            when skill in ('k8s', 'kubernetes') then 'kubernetes'
            when skill in ('ci/cd', 'cicd', 'ci cd') then 'ci/cd'
            when skill in ('ml', 'machine learning') then 'machine learning'
            when skill in ('dl', 'deep learning') then 'deep learning'
            when skill in ('sklearn', 'scikit-learn', 'scikit learn') then 'scikit-learn'
            when skill in ('nlp', 'natural language processing') then 'nlp'
            when skill in ('powerbi', 'power-bi', 'msbi', 'power bi') then 'power bi'
            when skill in ('looker studio', 'data studio', 'google data studio') then 'data studio'
            when skill in ('py', 'python3', 'python 3') then 'python'
            when skill in ('js', 'javascript') then 'javascript'
            when skill in ('ts', 'typescript') then 'typescript'
            when skill in ('golang', 'go lang') then 'golang'
            when skill in ('apache spark', 'pyspark') then 'spark'
            when skill in ('apache kafka') then 'kafka'
            when skill in ('apache airflow') then 'airflow'
            when skill in ('apache hive') then 'hive'
            else skill
        end as skill
    from base
)

select distinct job_id, skill, category
from normalized
where skill is not null and trim(skill) != ''