import pandas as pd

class Global_Info:
    """
    Prints out the global information like missing counts, shape, etc.
    Required parameters are filenames and dataframes
    Stat info is left to be added
    Once added, it will return the statistical summary like median, mean, etc for each df
    """
    def __init__(self, filenames: None, dataframes: None):
        self.fns = filenames
        self.dfs = dataframes

    def _missing_count(self, df):
        return df.isnull().sum()

    def _print_shape(self, df):
        return df.shape

    def _unique_cols(self, df):
        return df.columns.unique()

    def _data_type(self, df):
        return df.dtypes

    def base_info(self):
        for i, df in enumerate(self.dfs):
            print("----------------------------------------------------------------")
            print(f"{self.fns[i].strip('.csv')}")
            print("----------------------------------------------------------------")
            print(f'MISSING VALUES:\n {self._missing_count(df)}\n')
            print(f'SHAPE:\n{self._print_shape(df)}\n')
            print(f'UNIQUE COLUMNS:\n{self._unique_cols(df)}\n')
            print(f'COL DATA TYPES:\n{self._data_type(df)}\n\n')

    def cat_max_min(df, cat_cols):
        """
        This is a class method.
        It takes a df and the categorical cols then returns the min and max summary as a dataframe
        """
        summary = []
        for col in cat_cols:
            counts = df[col].value_counts()

            summary.append({
                'Column': col,
                'Most Frequent': counts.idxmax(),
                'Max Count': counts.max(),
                'Least Frequent': counts.idxmin(),
                'Min Count': counts.min()
            })

        summary_df = pd.DataFrame(summary)
        return summary_df


    