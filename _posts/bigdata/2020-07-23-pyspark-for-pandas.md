---
layout: post
title: PySpark for pandas
categories: [big data]
description: 官方文档解读
keywords: spark, pandas
catalog: true
multilingual: false
tags: big data
---

## Apache Arrow in PySpark
Spark可以使用`Apache Arrow`对python和jvm之间的数据进行传输， 这样会比默认传输更加高效。
为了能高效地利用特性和保障兼容性，使用的时候可能需要一点点修改或者配置。


## Spark DataFrame和Pandas DataFrame的转化
首先需要配置spark, 设置`spark.sql.execution.arrow.pyspark.enabled`, 默认这个选项是不打开的。
还可以开启`spark.sql.execution.arrow.pyspark.fallback.enabled`来避免如果没有安装`Arrow`或者其它相关错误。
Spark可以使用`toPandas()`方法转化为Pandas DataFrame; 而使用`createDataFrame(pandas_df)`把Pandas DataFrame转为Spark DataFrame.
```
import numpy as np
import pandas as pd

spark.conf.set('spark.sql.execution.arrow.pyspark.enabled', 'true')

pdf = pd.DataFrame(np.random.rand(100,3))

df = spark.createDataFrame(pdf)

# 使用arrow把spark df转化为pandas df
result_pdf = df.select(*).toPandas()
```

## Pandas UDF(矢量UDF)
`Pandas UDF`是用户定义的函数， Spark是用arrow传输数据和pandas， `pandas UDF`使用向量计算，可以最多增加100倍的性能，相比于旧版本的`row-at-a-time`python udf.
使用`pandas_udf`修饰器装饰函数，就可以定义一个`pandas UDF`.对spark来说，UDF就是一个普通的pyspark函数。
从spark3.0开始， 推荐使用python类型(`type hint`)来定义pandas udf.
定义类型的时候，`StructType`需要使用`pandas.DataFrame`类型， 其他一律使用`pandas.Series`类型。
```
import pandas as pd
from pyspark.sql.functions import pandas_udf

@pandas_udf("col1 string, col2 long")
def func(s1: pd.series, s2: pd.series, s3: pd.DataFrame) -> pd.DataFrame:
  s3['col2'] = s1+s2.str.len()
  s3['col1'] = 'sss'
  return s3
  
df = spark.createDataFrame(
      [[1, "a string", ("a nested string",)]],
      "long_col long, string_col string, struct_col struct<col1:string>")
      
df.printSchema()

df.select(func("long_col", "string_col", "struct_col")).printSchema()

df.select(func("long_col", "string_col", "struct_col")).show()     
+--------------------------------------+
|func(long_col, string_col, struct_col)|
+--------------------------------------+
|                              [sss, 9]|
+--------------------------------------+
```
