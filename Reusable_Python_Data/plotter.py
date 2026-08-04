import matplotlib.pyplot as plt

class Plotter:
    """
    Uses matplotlib to plot the data based on the method called.
    Takes dataframe, columns name list, and color's name list corresponding to the cols
    """
    def __init__(self, cols, colors, df):
        self.cols = cols
        self.colors = colors
        self.df = df

    def subplotter_cat_bar(self):
        fig, axes = plt.subplots(2, 3, figsize=(10, 5))
        axes = axes.flatten()

        for i, cat in enumerate(self.cols):
            counts = self.df[cat].value_counts()

            categories = counts.index
            values = counts.values

            axes[i].bar(categories, values, color=self.colors[i])
            axes[i].set_title(cat.replace("_", " ").title())
            axes[i].set_ylabel('Counts')
            axes[i].tick_params(axis='x', rotation=45)

        plt.tight_layout()
        plt.show()