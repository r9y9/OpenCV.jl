using OpenCV

cap = cv2.VideoCapture(0)

isescape(key) = key == 27

while (true)
    ok, img = cv2.read(cap)
    s = cv2.size(img)
    w, h = cv2.width(s), cv2.height(s)

    img = cv2.resize(img, (w/4, h/4))
    gray = cv2.cvtColor(img, cv2.COLOR_RGB2GRAY)
    bin = cv2.threshold(gray, 170, 255, cv2.THRESH_OTSU)

    cv2.imshow("gray", gray)
    cv2.imshow("binary threshold", bin)

    key = cv2.waitKey(delay=1)
    isescape(key) && break
end

cv2.release(cap)
cv2.destroyAllWindows()