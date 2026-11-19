import pandas as pd
import seaborn as sns
import gradio as gr
from sklearn.model_selection import train_test_split
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import OneHotEncoder
from sklearn.impute import SimpleImputer
from sklearn.pipeline import Pipeline
from sklearn.tree import DecisionTreeClassifier
from sklearn.metrics import accuracy_score

df = sns.load_dataset("titanic")
features = ["pclass", "sex", "age", "sibsp", "parch", "fare", "embarked"]
X, y = df[features].copy(), df["survived"].copy()

numeric = ["pclass", "age", "sibsp", "parch", "fare"]
categorical = ["sex", "embarked"]

preprocessor = ColumnTransformer([
    ("num", Pipeline([("imputer", SimpleImputer(strategy="median"))]), numeric),
    ("cat", Pipeline([
        ("imputer", SimpleImputer(strategy="most_frequent")),
        ("onehot", OneHotEncoder(handle_unknown="ignore"))
    ]), categorical)
])

model = Pipeline([
    ("preprocessor", preprocessor),
    ("classifier", DecisionTreeClassifier(
        max_depth=4, min_samples_split=10, min_samples_leaf=5, random_state=42
    ))
])

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.20, random_state=42, stratify=y
)
model.fit(X_train, y_train)
accuracy = accuracy_score(y_test, model.predict(X_test))

def predict_survival(pclass, sex, age, sibsp, parch, fare, embarked):
    passenger = pd.DataFrame([{
        "pclass": int(pclass), "sex": sex, "age": float(age),
        "sibsp": int(sibsp), "parch": int(parch),
        "fare": float(fare), "embarked": embarked
    }])
    pred = int(model.predict(passenger)[0])
    probs = model.predict_proba(passenger)[0]
    label = "Survived" if pred == 1 else "Did not survive"
    return (
        f"### Prediction: {label}\\n**Estimated probability for this prediction:** {probs[pred]:.1%}\\n"
        f"**Held-out test accuracy:** {accuracy:.1%}",
        {"Did not survive": float(probs[0]), "Survived": float(probs[1])}
    )

with gr.Blocks(theme=gr.themes.Soft(), title="Titanic Survival Predictor") as demo:
    gr.Markdown("# Titanic Survival Predictor\\nAdjust the inputs and predict survival.")
    with gr.Row():
        with gr.Column():
            pclass = gr.Dropdown([1, 2, 3], value=3, label="Passenger class")
            sex = gr.Radio(["female", "male"], value="male", label="Gender")
            age = gr.Slider(0, 80, value=25, step=1, label="Age")
            sibsp = gr.Slider(0, 8, value=0, step=1, label="Siblings / spouses aboard")
            parch = gr.Slider(0, 6, value=0, step=1, label="Parents / children aboard")
            fare = gr.Slider(0, 513, value=7.25, step=0.25, label="Ticket fare")
            embarked = gr.Dropdown(["S", "C", "Q"], value="S", label="Port of embarkation")
            button = gr.Button("Predict Survival", variant="primary")
        with gr.Column():
            result = gr.Markdown()
            probabilities = gr.Label(num_top_classes=2, label="Class probabilities")
    button.click(predict_survival, [pclass, sex, age, sibsp, parch, fare, embarked],
                 [result, probabilities])
    gr.Markdown(f"Decision Tree classifier · Held-out test accuracy: {accuracy:.1%}. Educational demo only.")

if __name__ == "__main__":
    demo.launch()
