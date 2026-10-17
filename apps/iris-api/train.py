import joblib
from sklearn.datasets import load_iris
from sklearn.linear_model import LogisticRegression

iris = load_iris()
model = LogisticRegression(max_iter=500).fit(iris.data, iris.target)
joblib.dump({"model": model, "classes": list(iris.target_names)}, "/app/model.joblib")
print("trained, accuracy on train:", round(model.score(iris.data, iris.target), 3))
