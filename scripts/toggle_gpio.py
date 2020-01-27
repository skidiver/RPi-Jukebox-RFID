import argparse
import RPi.GPIO as GPIO

trueValues = {'yes', 'true', 't', 'y', '1'}
falseValues = {'no', 'false', 'f', 'n', '0'}

def str2bool(v):
    if isinstance(v, bool):
        return v
    if v.lower() in trueValues:
        return True
    elif v.lower() in falseValues:
        return False
    else:
        raise argparse.ArgumentTypeError('Boolean value expected.')

def bool2state(v):
    if v:
        return GPIO.HIGH
    else:
        return GPIO.LOW

parser = argparse.ArgumentParser()
parser.add_argument("number", help="number of the GPIO pin", type=int)
parser.add_argument("activate", help="pin activated ("+str(list(trueValues))+") / deactivated ("+str(list(falseValues))+")", type=str2bool, nargs=1)
args = parser.parse_args()

#print('number=' + str(args.number))
activate=args.activate[0]
#print('activate=' + str(activate))

GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)
GPIO.setup(args.number,GPIO.OUT)
state = bool2state(activate)
print('Setting GPIO' + str(args.number) + ' to ' + str(state))
GPIO.output(args.number,state)
