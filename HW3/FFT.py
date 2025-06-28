import struct

class Weight:
    def __init__( self, real, image):
        self.real = real
        self.image =  image

    def __str__(self):
        return f"Weight(real={self.real}=({decimal_to_custom_binary(self.real)}), image={self.image})=({decimal_to_custom_binary(self.image)})"
    
class Data:
    def __init__( self, real, image):
        self.real = real
        self.image = image
    def __str__(self):
        return f"Data(real={self.real}=({decimal_to_custom_binary(self.real)}), image={self.image})=({decimal_to_custom_binary(self.image)})"

def decimal_to_custom_binary(decimal_num):
    if decimal_num >= 0:
        sign_bit = '0'
        k = decimal_num
    else:
        sign_bit = '0'
        k = decimal_num
        decimal_num = abs(decimal_num)

    integer_part = int(decimal_num)
    fractional_part = decimal_num - integer_part

    if integer_part > 127:
        return "整數部分超出表示範圍"

    integer_binary = format(integer_part, '07b')

    fractional_value = round(fractional_part * 256)
    if fractional_value > 255:
        return "小數部分超出表示範圍"
    fractional_binary = format(fractional_value, '08b')

    binary_representation = sign_bit + integer_binary + fractional_binary
    if k < 0:
        # 二補數
        inverted_binary = ''.join(['1' if bit == '0' else '0' for bit in binary_representation])
        carry = 1
        temp_list = list(inverted_binary)
        for i in range(len(temp_list) - 1, -2, -1):
            if temp_list[i] == '0' and carry == 1:
                temp_list[i] = '1'
                carry = 0
                break
            elif temp_list[i] == '1' and carry == 1:
                temp_list[i] = '0'
            # 如果 carry 仍然是 1 並且已經到最高位，這在我們的 16 位表示中不應該發生

        binary_representation = "".join(temp_list)

    # 轉換為十六進制
    hex_representation = hex(int(binary_representation, 2))[2:].upper().zfill(4)

    return hex_representation

def format_data(datas):
    return [Data(round(d.real * 2**8) / 2**8, round(d.image * 2**8) / 2**8)for d in datas]

weights_image = [000, -3.826752e-001, -7.070923e-001, -9.238739e-001,
-1, -9.238739e-001, -7.070923e-001, -3.826752e-001]
weights_real = [1, 9.238739e-001, 7.070923e-001, 3.826752e-001, 
000, -3.826752e-001, -7.070923e-001, -9.238739e-001]

weights = [Weight(r, i) for r, i in zip(weights_real, weights_image)]
print(len(weights))
datas_real = [
    5.585938e-001, 8.437500e-001, 9.804688e-001, 9.531250e-001, 7.578125e-001, 4.335938e-001, 3.515625e-002, -3.671875e-001, 
    -7.070313e-001, -9.296875e-001, -9.882813e-001, -8.789063e-001, -6.171875e-001, -2.500000e-001, 1.562500e-001, 5.390625e-001
]

datas = [Data(r, 0) for r in datas_real]

# stage_1_data = []
def FFT_stage_1(datas: list, weights):
    result = [0] * 16
    print("len(datas)//2", len(datas)//2)
    for i in range(0, len(datas)//2):
        print(i)
        result[i] = Data( datas[i].real + datas[i+8].real, datas[i].image + datas[i+8].image)
        result[i+8] = Data( (datas[i].real - datas[i+8].real) * weights[i].real, 
                           (datas[i].real - datas[i+8].real) * weights[i].image)
    return result

stage_1_data = format_data(FFT_stage_1(datas, weights))

for i in range(len(stage_1_data)):
    print(i, stage_1_data[i])


def FFT_stage_2(datas: list, weights):
    result = [0] * 16
    for offset in [0, 8]:
        for i in range(0, len(datas)//4):
            result[i+ offset] = Data( datas[i+ offset].real + datas[i+ offset+4].real, datas[i+ offset].image + datas[i+ offset+4].image)
            temp_real = (datas[i+ offset].real - datas[i+ offset+4].real)
            temp_image = (datas[i+ offset].image - datas[i+ offset+4].image)

            result[i+ offset+4] = Data( temp_real * weights[2*i].real
                                       - temp_image * weights[2*i].image, 
                                        temp_real * weights[2*i].image
                                        + temp_image * weights[2*i].real)
    return result


stage_2_data = format_data(FFT_stage_2(stage_1_data, weights))
for i in range(len(stage_2_data)):
    print(i, stage_2_data[i])