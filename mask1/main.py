from keras.models import load_model
from PIL import Image, ImageOps 
import numpy as np
from flask import Flask,request
import werkzeug

app= Flask(__name__)

@app.route('/api1', methods=["POST"])
def upload_and_detect1():
			if(request.method=="POST"):
					imagefile= request.files['image']
					filename=werkzeug.utils.secure_filename(imagefile.filename)
					imagefile.save("./uploaded1/"+filename)
					
			res={}
			np.set_printoptions(suppress=True)

			model = load_model('MASK.h5', compile=False)
			file="./uploaded1/"+filename
			
			labels = open('labels_mask.txt', 'r').readlines()

			data = np.ndarray(shape=(1, 224, 224, 3), dtype=np.float32)

			image = Image.open(file).convert('RGB')

			size = (224, 224)
			image = ImageOps.fit(image, size, Image.Resampling.LANCZOS)

			image_array = np.asarray(image)

			normalized_image_array = (image_array.astype(np.float32) / 127.0) - 1

			data[0] = normalized_image_array

			prediction = model.predict(data)
			index = np.argmax(prediction)
			class_name = labels[index]
			confidence_score = prediction[0][index]
			res['output']=class_name
			res['confidence']=str(confidence_score)
			return res

if __name__=="__main__":
        app.run(debug=True,port=8080)

