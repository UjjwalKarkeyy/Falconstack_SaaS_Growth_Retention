import os
import pandas as pd

class Filenames_To_Dataframes:
    """
    Takes data folder path that contains all the data files
    returns the list of dataframes and their respective file names

    note: Only works with '.csv' files. Change ".csv" to other extension of your choice in _get_file_names & _create_dataframes
    """
    # path -> data folder path, e.x., 'HR_Data_Analysis/data/*.csv
    def __init__(self, path):
        self.path = path

    # returns file names in list
    def _get_file_names(self):
        data_file_locs = []
        for filename in os.listdir(self.path):
            if filename.endswith(".csv"):
                data_file_locs.append(filename)
        return data_file_locs

    def _create_dataframes(self, file_names):
        data_frames = []
        for fn in file_names:
            name = f"{fn.strip('.csv')}_df"
            data = pd.read_csv(f"{self.path}\\{fn}")
            name = pd.DataFrame(data)
            data_frames.append(name)
        return data_frames

    def get_dataframes(self):
        file_names = self._get_file_names()
        return self._create_dataframes(file_names), file_names