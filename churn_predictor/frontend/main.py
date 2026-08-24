from pathlib import Path
import json

import pandas as pd
from fastapi import FastAPI
from fastapi.responses import HTMLResponse
from pydantic import BaseModel
from xgboost import XGBClassifier


# -------------------------------------------------
# FastAPI app
# -------------------------------------------------

app = FastAPI(
    title="Falconstack Churn Predictor",
    version="1.0.0"
)


# -------------------------------------------------
# Global paths
# -------------------------------------------------

gbl_pth = r'd:\GitHub\Falconstack_SaaS_Growth_Retention'

model_dir = (
    Path(gbl_pth)
    / 'churn_predictor'
    / 'exported_model'
)

model_path = model_dir / 'xgb_churn_predictor.json'
metadata_path = model_dir / 'xgb_churn_metadata.json'


# -------------------------------------------------
# Validate model files
# -------------------------------------------------

if not model_path.exists():
    raise FileNotFoundError(
        f"Model file not found: {model_path}"
    )

if not metadata_path.exists():
    raise FileNotFoundError(
        f"Metadata file not found: {metadata_path}"
    )


# -------------------------------------------------
# Load model
# -------------------------------------------------

model = XGBClassifier()
model.load_model(model_path)


# -------------------------------------------------
# Load metadata
# -------------------------------------------------

with open(metadata_path, 'r', encoding='utf-8') as f:
    metadata = json.load(f)


# -------------------------------------------------
# Request schema
# -------------------------------------------------

class PredictionInput(BaseModel):
    is_trial: bool

    referral_source: str
    industry: str
    plan_tier: str

    upgrade_flag: bool
    downgrade_flag: bool

    usage_count: float
    usage_duration_secs: float
    error_count: float
    tickets_count: float


# -------------------------------------------------
# Helper values for frontend dropdowns
# -------------------------------------------------

referral_sources = metadata.get(
    "categories",
    {}
).get(
    "referral_source",
    []
)

industries = metadata.get(
    "categories",
    {}
).get(
    "industry",
    []
)

plan_tiers = metadata.get(
    "categories",
    {}
).get(
    "plan_tier",
    []
)


def build_options(values):
    return "".join(
        f'<option value="{value}">{value}</option>'
        for value in values
    )


referral_options = build_options(referral_sources)
industry_options = build_options(industries)
plan_tier_options = build_options(plan_tiers)


# -------------------------------------------------
# Frontend HTML
# -------------------------------------------------

HTML = f"""
<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta
        name="viewport"
        content="width=device-width, initial-scale=1.0"
    >

    <title>Falconstack Churn Predictor</title>


    <style>

        * {{
            box-sizing: border-box;
        }}

        body {{
            font-family:
                Arial,
                Helvetica,
                sans-serif;

            background: #f4f6f8;

            margin: 0;

            padding: 40px 20px;

            color: #222;
        }}


        .container {{
            max-width: 760px;
            margin: auto;
        }}


        .card {{
            background: white;

            padding: 30px;

            border-radius: 14px;

            box-shadow:
                0 5px 20px
                rgba(0, 0, 0, 0.08);
        }}


        h1 {{
            margin-top: 0;
            margin-bottom: 8px;
        }}


        .subtitle {{
            color: #666;
            margin-bottom: 30px;
        }}


        .grid {{
            display: grid;

            grid-template-columns:
                repeat(
                    2,
                    minmax(0, 1fr)
                );

            gap: 20px;
        }}


        .field {{
            display: flex;
            flex-direction: column;
        }}


        label {{
            margin-bottom: 7px;

            font-weight: 600;

            font-size: 14px;
        }}


        input,
        select {{
            width: 100%;

            padding: 11px 12px;

            border:
                1px solid #ccc;

            border-radius: 7px;

            font-size: 15px;

            background: white;
        }}


        input:focus,
        select:focus {{
            outline: none;

            border-color: #555;
        }}


        button {{
            width: 100%;

            margin-top: 28px;

            padding: 13px;

            border: none;

            border-radius: 8px;

            font-size: 16px;

            font-weight: 600;

            cursor: pointer;
        }}


        #result {{
            display: none;

            margin-top: 25px;

            padding: 20px;

            border-radius: 10px;

            background: #f0f2f4;
        }}


        .result-title {{
            font-size: 18px;
            font-weight: bold;
            margin-bottom: 12px;
        }}


        .metric {{
            margin-top: 8px;
        }}


        .error {{
            color: #b00020;
        }}


        @media (
            max-width: 650px
        ) {{

            .grid {{
                grid-template-columns:
                    1fr;
            }}

        }}

    </style>

</head>


<body>


<div class="container">

    <div class="card">

        <h1>
            Customer Churn Predictor
        </h1>

        <form id="predictionForm">


            <div class="grid">


                <div class="field">

                    <label for="is_trial">
                        Trial Account
                    </label>

                    <select id="is_trial">

                        <option value="false">
                            No
                        </option>

                        <option value="true">
                            Yes
                        </option>

                    </select>

                </div>


                <div class="field">

                    <label for="referral_source">
                        Referral Source
                    </label>

                    <select
                        id="referral_source"
                        required
                    >

                        {referral_options}

                    </select>

                </div>


                <div class="field">

                    <label for="industry">
                        Industry
                    </label>

                    <select
                        id="industry"
                        required
                    >

                        {industry_options}

                    </select>

                </div>


                <div class="field">

                    <label for="plan_tier">
                        Plan Tier
                    </label>

                    <select
                        id="plan_tier"
                        required
                    >

                        {plan_tier_options}

                    </select>

                </div>


                <div class="field">

                    <label for="upgrade_flag">
                        Upgraded
                    </label>

                    <select id="upgrade_flag">

                        <option value="false">
                            No
                        </option>

                        <option value="true">
                            Yes
                        </option>

                    </select>

                </div>


                <div class="field">

                    <label for="downgrade_flag">
                        Downgraded
                    </label>

                    <select id="downgrade_flag">

                        <option value="false">
                            No
                        </option>

                        <option value="true">
                            Yes
                        </option>

                    </select>

                </div>


                <div class="field">

                    <label for="usage_count">
                        Usage Count
                    </label>

                    <input
                        id="usage_count"
                        type="number"
                        step="any"
                        min="0"
                        required
                    >

                </div>


                <div class="field">

                    <label for="usage_duration_secs">
                        Usage Duration (seconds)
                    </label>

                    <input
                        id="usage_duration_secs"
                        type="number"
                        step="any"
                        min="0"
                        required
                    >

                </div>


                <div class="field">

                    <label for="error_count">
                        Error Count
                    </label>

                    <input
                        id="error_count"
                        type="number"
                        step="any"
                        min="0"
                        required
                    >

                </div>


                <div class="field">

                    <label for="tickets_count">
                        Support Ticket Count
                    </label>

                    <input
                        id="tickets_count"
                        type="number"
                        step="any"
                        min="0"
                        required
                    >

                </div>


            </div>


            <button type="submit">
                Predict Churn
            </button>


        </form>


        <div id="result"></div>


    </div>

</div>


<script>

    const form =
        document.getElementById(
            "predictionForm"
        );


    const resultDiv =
        document.getElementById(
            "result"
        );


    form.addEventListener(
        "submit",
        async function(event) {{

            event.preventDefault();


            resultDiv.style.display =
                "block";

            resultDiv.innerHTML =
                "Calculating prediction...";


            const payload = {{

                is_trial:
                    document.getElementById(
                        "is_trial"
                    ).value === "true",


                referral_source:
                    document.getElementById(
                        "referral_source"
                    ).value,


                industry:
                    document.getElementById(
                        "industry"
                    ).value,


                plan_tier:
                    document.getElementById(
                        "plan_tier"
                    ).value,


                upgrade_flag:
                    document.getElementById(
                        "upgrade_flag"
                    ).value === "true",


                downgrade_flag:
                    document.getElementById(
                        "downgrade_flag"
                    ).value === "true",


                usage_count:
                    Number(
                        document.getElementById(
                            "usage_count"
                        ).value
                    ),


                usage_duration_secs:
                    Number(
                        document.getElementById(
                            "usage_duration_secs"
                        ).value
                    ),


                error_count:
                    Number(
                        document.getElementById(
                            "error_count"
                        ).value
                    ),


                tickets_count:
                    Number(
                        document.getElementById(
                            "tickets_count"
                        ).value
                    )

            }};


            try {{

                const response =
                    await fetch(
                        "/predict",
                        {{
                            method: "POST",

                            headers: {{
                                "Content-Type":
                                    "application/json"
                            }},

                            body:
                                JSON.stringify(
                                    payload
                                )
                        }}
                    );


                const data =
                    await response.json();


                if (!response.ok) {{

                    throw new Error(
                        data.detail ||
                        "Prediction request failed."
                    );

                }}


                resultDiv.innerHTML = `

                    <div class="result-title">

                        ${{data.prediction}}

                    </div>


                    <div class="metric">

                        <strong>
                            Churn probability:
                        </strong>

                        ${{
                            (
                                data.churn_probability
                                * 100
                            ).toFixed(2)
                        }}%

                    </div>


                    <div class="metric">

                        <strong>
                            Stay probability:
                        </strong>

                        ${{
                            (
                                data.stay_probability
                                * 100
                            ).toFixed(2)
                        }}%

                    </div>
                `;

            }}

            catch (error) {{

                resultDiv.innerHTML = `

                    <div class="error">

                        <strong>Error:</strong>

                        ${{error.message}}

                    </div>

                `;

            }}

        }}
    );

</script>


</body>

</html>
"""


# -------------------------------------------------
# Home route
# -------------------------------------------------

@app.get(
    "/",
    response_class=HTMLResponse
)
def home():

    return HTML


# -------------------------------------------------
# Prediction route
# -------------------------------------------------

@app.post("/predict")
def predict(
    data: PredictionInput
):

    # ---------------------------------------------
    # Convert incoming request to DataFrame
    # ---------------------------------------------

    input_df = pd.DataFrame(
        [data.model_dump()]
    )


    # ---------------------------------------------
    # Restore categorical dtypes
    # ---------------------------------------------

    categorical_columns = metadata.get(
        "categorical_columns",
        []
    )

    categories = metadata.get(
        "categories",
        {}
    )


    for col in categorical_columns:

        input_df[col] = pd.Categorical(
            input_df[col],
            categories=categories[col]
        )


    # ---------------------------------------------
    # Enforce training feature order
    # ---------------------------------------------

    feature_columns = metadata[
        "feature_columns"
    ]

    input_df = input_df[
        feature_columns
    ]


    # ---------------------------------------------
    # Predict probability
    # ---------------------------------------------

    prediction_probabilities = (
        model.predict_proba(
            input_df
        )[0]
    )


    stay_probability = float(
        prediction_probabilities[0]
    )

    churn_probability = float(
        prediction_probabilities[1]
    )


    # ---------------------------------------------
    # Decision threshold
    # ---------------------------------------------

    threshold = float(
        metadata.get(
            "threshold",
            0.5
        )
    )


    churn_prediction = (
        churn_probability
        >= threshold
    )


    prediction_label = (
        "Likely to Churn"
        if churn_prediction
        else "Likely to Stay"
    )


    # ---------------------------------------------
    # Response
    # ---------------------------------------------

    return {

        "prediction":
            prediction_label,

        "churn_prediction":
            churn_prediction,

        "churn_probability":
            churn_probability,

        "stay_probability":
            stay_probability
    }


# -------------------------------------------------
# Run directly with:
#
# python main.py
# -------------------------------------------------

if __name__ == "__main__":

    import uvicorn

    uvicorn.run(
        "main:app",
        host="127.0.0.1",
        port=8000,
        reload=True
    )