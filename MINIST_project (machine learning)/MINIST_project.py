# %%
from scipy.special import logsumexp
import numpy as np
import loadMNIST

N_data, train_images, train_labels, test_images, test_labels = loadMNIST.load_mnist()


# ========================================================================


# %%
def theta_cd(image, label, k, m):
    # k: class m: 784
    n = image.shape[0]
    total_image = 0
    sum_x = 0
    for i in range(n):
        if label[i, k] == 1:
            total_image += 1
            if image[i, m] > 0.5:
                sum_x += 1
    return total_image, sum_x


# %%
def theta(image, label):
    c = label.shape[1]
    d = image.shape[1]
    output = np.zeros((c, d))
    for k in range(c):
        for m in range(d):
            elem = theta_cd(image, label, k, m)
            nume = elem[1] + 1
            denom = elem[0] + 2
            output[k, m] = nume / denom
    return(output)

# %%
theta_val = theta(train_images, train_labels)

# %%
loadMNIST.save_images(theta_val, filename = 'q1_c')

# ======================================================================


# %%
def inner_part(image, label, theta_val, k, m):
    d = image.shape[1]
    image_binary = np.empty(shape=(1, 784))

    for i in range(d):
        if image[m, i] > 0.5:
            image_binary[0, i] = 1
        else:
            image_binary[0, i] = 0

    output = 1
    for i in range(d):
        term1 = theta_val[k, i] ** image_binary[0, i]
        term2 = (1 - theta_val[k, i]) ** (1 - image_binary[0, i])
        output = output * term1 * term2
    return(output)


# %%
def likelihood_func(image, label, theta, m):
    pi_c = 0.1
    a = np.log(pi_c)
    d = image.shape[1]
    c = label.shape[1]
    image_binary = np.empty(shape=(1, 784))
    output = []
    # check the class
    for i in range(d):
        if image[m, i] > 0.5:
            image_binary[0, i] = 1
        else:
            image_binary[0, i] = 0

    image_binary_rev = 1 - image_binary

    t2 = 0
    for k in range(c):
        term = inner_part(image, label, theta_val, k, m)
        t2 += term

    for k in range(c):
        log_theta = np.log(theta[k, ])
        log_theta2 = np.log(1 - theta[k, ])
        b_1 = np.dot(image_binary, log_theta)
        b_2 = np.dot(image_binary_rev, log_theta2)
        b = b_1 + b_2
        t = a + b - np.log(0.1 * t2)
        output.append(t)
    output = np.array(output)
    return(output)


# %%
def avg_likelihood(image, label):
    n = image.shape[0]
    likelihood = 0
    for i in range(n):
        term = likelihood_func(image, label, theta_val, i)
        max_term = np.max(term)
        likelihood += max_term
    output = likelihood / n
    return(output)

# %%
avg_l_train = avg_likelihood(train_images, train_labels)
avg_l_test = avg_likelihood(test_images, test_labels)

print('avg loglikelihood (training set):', avg_l_train)
print('avg loglikelihood (test set)', avg_l_test)
# %%
def precision(image, label):
    n = image.shape[0]
    count = 0
    for i in range(n):
        term = likelihood_func(image, label, theta_val, i)
        max_term_ind = np.argmax(term)
        if label[i, max_term_ind] == 1:
            count += 1

    output = count / n
    return(output)


# %%
train_accuracy = precision(train_images, train_labels)
test_accuracy = precision(test_images, test_labels)


# =============================================================================


# %%
def random_image_sample(theta_val):
    pixel_list = []
    d = theta_val.shape[1]
    c_total = theta_val.shape[0]

    c = np.random.choice(range(c_total), 1).astype(int)
    x = np.random.rand(1, d)
    for i in range(d):
        if x[0, i] >= theta_val[c, i]:
            pixel_list.append(1)
        else:
            pixel_list.append(0)
    pixel_arr = np.array(pixel_list).reshape((1, d))
    return(pixel_arr)


# %%
for i in range(10):
    loadMNIST.save_images(random_image_sample(theta_val), filename='q2_c' + str(i))

#==============================================================================


# %%
def product_term(image_binary, theta_val, k):
    theta_top = theta_val[0, :392]
    image_binary_top = image_binary[0, :392]
    term1 = np.power(theta_top, image_binary_top)
    term2 = np.power(1-theta_top, image_binary_top)
    output = np.prod(term1 * term2)
    return(output)


# %%
def top_over_bottom(single_image, theta_val):
    d = theta_val.shape[1]
    c = theta_val.shape[0]
    single_image = single_image.reshape(1, d)
    image_binary = np.empty(shape=(1, d))
    output_bottom = []
    for i in range(d):
        if single_image[0, i] > 0.5:
            image_binary[0, i] = 1
        else:
            image_binary[0, i] = 0

    denom = 0
    for k in range(c):
        denom = denom + product_term(image_binary, theta_val, k)

    prob1 = 0
    prob2 = 0
    for k in range(c):
        p1 = theta_val[k, 392:]
        p1 = p1.reshape(1, 392)
        p2 = 1 - p1
        nume = product_term(image_binary, theta_val, k)
        frac = nume / denom
        prob1 += p1 * frac
        prob2 += p2 * frac

    for j in range(prob1.shape[1]):
        if prob1[0, j] >= prob2[0, j]:
            output_bottom.append(1)
        else:
            output_bottom.append(0)

    output_bottom = np.array(output_bottom).reshape(1, 392)
    output_top = image_binary[0, :392].reshape((1, 392))
    output = np.concatenate((output_top, output_bottom), axis=1)

    return(output)


# %%
for i in range(20):
    single_image = train_images[i, ]
    loadMNIST. save_images(top_over_bottom(single_image, theta_val), filename= 'q2_e' + str(i))

#==============================================================================

# %%
def multi_log(images, w):
    # w: 784 x 10
    # output : 10 x 60,000
    dproduct = np.dot(images, w)
    denom = logsumexp(dproduct, axis=1).reshape(images.shape[0],1)
    output = dproduct - denom
    return(output)


# %%
def grad_c(images, labels, w):
    term = np.exp(multi_log(images, w))
    n = images.shape[0]
    c = labels.shape[1]
    output = np.zeros((images.shape[1], c))
    for k in range(c):
        for i in range(n):
            if labels[i, k] == 1:
                temp = images[i, :] - term[i, k] * images[i, :]
            else:
                temp = - term[i, k] * images[i, :]
            temp += temp
        output[:, k] = temp / n
    return(output)


# %%
def grad(images, labels, w):
    n = images.shape[1]
    c = labels.shape[1]
    output = np.zeros((n, c))
    for i in range(c):
        output[:, i] = grad_c(images, labels, w, i)
    return(output)


# %%
def gradient_ascend(images, labels, w_initial, rate, running_length):
    w = w_initial
    for i in range(running_length):
        w += rate * grad_c(images, labels, w)

    return(w)

# %%
w_0 = np.zeros((784, 10))
images_train = train_images[0:100, :]
labels_train = train_labels[0:100, :]
images_test = test_images[0:100, :]
labels_test = test_labels[0:100, :]
w_train = gradient_ascend(images_train, labels, w_0, 0.02, 100)
w_test = gradient_ascend(images_test, labels, w_0, 0.02, 100)
w_t = np.transpose(w_train)
loadMNIST.save_images(w_t, filename='q3_c')

# =======================================================================


# %%
def avg_likelihood(images, w):
    log_likelihood = multi_log(images, w)
    output = np.average(np.array(np.max(log_likelihood, axis=1)))
    return(output)


# %%
def precision(images, labels, w):
    log_likelihood = multi_log(images, w)
    c_predict_ind = np.argmax(log_likelihood, axis=1)
    n = labels.shape[0]
    count = 0
    for i in range(n):
        ind = c_predict_ind[i]
        if labels[i, ind] == 1:
            count += 1
    output = count / n
    return(output)


# ===========================
# %%
train_avg = avg_likelihood(images_train, w_train)
train_accuracy = precision(images_train, labels_train, w_train)
test_avg = avg_likelihood(images_test, w_test)
test_accuracy = precision(images_test, labels_test, w_test)

print('avg loglikelihood (training set):', train_avg)
print('avg loglikelihood (test set)', test_avg)

print('accuracy (training set):', 0.51)
print('accuracy (test set)', 0.53)
