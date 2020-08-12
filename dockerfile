FROM python:3.8

WORKDIR /jup

COPY requirements.txt ./

RUN pip install --no-cache-dir -r requirements.txt

RUN rm requirements.txt

COPY jupyter_notebook_config.py /root/.jupyter/

EXPOSE 8888

ENTRYPOINT ["jupyter", "lab","--ip=0.0.0.0","--no-browser", "--allow-root"]