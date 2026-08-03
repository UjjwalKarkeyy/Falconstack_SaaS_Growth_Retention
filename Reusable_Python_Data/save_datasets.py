from pathlib import Path

class Save_Dataset:
    """
    Takes a list of dataframes, saving path, and list of filenames
    then stores those dataframes in the provided path under the respective filename
    Stores the dataframes as '.csv'
    """
    def __init__(self, dataframes, save_path, filenames):
        self.dfs = dataframes
        self.path = save_path
        self.fns = filenames

    def save_in_csv(self):
        for i, df in enumerate(self.dfs):
            path = Path(self.path) / self.fns[i]
            try:
                df.to_csv(path, index=False)
            except Exception as e:
                print(f'Exception Occurred: {e}')
                return 0

    

    

    

    

