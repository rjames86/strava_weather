import re
import requests

RWGS_API_ENDPOINT = 'https://ridewithgps.com'

ENDPOINTS = dict (
    user_detail = '/users/{id}.json',
    route_details = '/routes/{id}.json',
    trip_details = '/trips/{id}.json',
    user_routes = '/users/{id}/routes.json',
    user_rides = '/users/{id}/trips.json',
    # user_search = '/users/search.json',
    # route_search = '/find/search.json',
    # new_ride_from_points = '/trips.json',
    # new_ride_from_file = '/trips.json',
    # queued_task_status = '/queued_tasks/status.json',
)

def get_endpoint(components):
    search = re.compile(r'\/(\w+)')
    for _, endpoint in ENDPOINTS.items():
        if components == search.findall(endpoint):
            return RWGS_API_ENDPOINT + endpoint
    return ''


class RWGSCall(object):
    def __init__(self, key, path):
        self.key = key
        self.api_version = 2
        self.components = [path]

    def __getattr__(self, k):
        self.components.append(k)
        return self

    def __getitem__(self, k):
        self.components.append(k)
        return self

    def __call__(self, *args, **kwargs):
        try:
            endpoint = get_endpoint(self.components).format(**kwargs)
        except KeyError as e:
            raise Exception('Missing parameter', e.message)

        print get_endpoint(self.components).format(**kwargs)
        resp = requests.get(get_endpoint(self.components).format(**kwargs), params=self.params)
        return resp.json()

    @property
    def params(self):
        return dict(
            apikey=self.key,
            version=self.api_version
        )

class RWGS(object):
    def __init__(self, token):
        self.token = token

    def __getattr__(self, k):
        return RWGSCall(self.token, k)

# if __name__ == '__main__':
#     r = RWGS('f7faf5ac')
#     print r.routes()

