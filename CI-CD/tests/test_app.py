import pytest
import requests

def test_sample():
    response = requests.get('https://jsonplaceholder.typicode.com/posts/1')
    assert response.status_code == 200

def test_addition():
    assert 1 + 1 == 2
