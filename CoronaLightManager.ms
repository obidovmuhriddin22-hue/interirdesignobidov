-- ============================================================
--  CORONA LIGHT MANAGER PRO v3.0
--  3ds Max 2024 + Corona Renderer 12
--  SCROLLABLE — tepa-pastga surish imkoniyati
--  Har bir chiroqni alohida boshqarish
-- ============================================================

macroScript CoronaLightManagerPro
    category:"Corona Tools"
    tooltip:"Corona Light Manager Pro"
    buttonText:"Light Manager"
    icon:#("Standard",24)
(

-- ============================================================
-- GLOBAL
-- ============================================================
global CLM_Dialog = undefined
global CLM_LightsList = #()
global CLM_SoloedLight = undefined

-- ============================================================
-- YORDAMCHI FUNKSIYALAR (rollout lardan tashqarida)
-- ============================================================
fn CLM_GetCoronaLights = (
    local arr = #()
    for obj in objects where (classof obj == CoronaLight) do append arr obj
    arr
)

fn CLM_GetSelectedFromList = (
    local result = #()
    try (
        local sel = CLM_Dialog.rol_lights.mlb_lights.selection
        for i in sel where (i > 0 and i <= CLM_LightsList.count) do
            append result CLM_LightsList[i]
    ) catch()
    result
)

fn CLM_RefreshList = (
    CLM_LightsList = CLM_GetCoronaLights()
    local names = #()
    for lt in CLM_LightsList do (
        local state = if lt.enabled then " [ON]  " else " [OFF] "
        local info = state + lt.name + "  |  Int: " + (lt.intensity as string)
        append names info
    )
    try (
        CLM_Dialog.rol_lights.mlb_lights.items = names
        CLM_Dialog.rol_lights.lbl_count.text = ("Jami: " + (CLM_LightsList.count as string) + " ta chiroq")
    ) catch()
)

-- ============================================================
-- 1-ROLLOUT: CHIROQLAR RO'YXATI
-- ============================================================
rollout rol_lights "Chiroqlar Ro'yxati" (

    multilistbox mlb_lights "Sahnadagi Corona chiroqlar:" height:8 width:430
    label lbl_count "Jami: 0 ta chiroq" align:#left

    button btn_refresh    "Yangilash"       width:135 height:26 across:3
    button btn_sel_all    "Barchasini Belgilash"  width:135 height:26
    button btn_sel_none   "Belgilashni Olib Tashlash" width:135 height:26

    on btn_refresh pressed do CLM_RefreshList()

    on btn_sel_all pressed do (
        mlb_lights.selection = #{1..CLM_LightsList.count}
    )

    on btn_sel_none pressed do (
        mlb_lights.selection = #{}
    )

    on mlb_lights selectionEnd do (
        local sel = CLM_GetSelectedFromList()
        if sel.count == 1 do (
            local lt = sel[1]
            try (
                CLM_Dialog.rol_intensity.spn_intensity.value = lt.intensity
                CLM_Dialog.rol_color.cp_color.color = lt.color
                CLM_Dialog.rol_kelvin.spn_kelvin.value = lt.colorTemperature
                CLM_Dialog.rol_kelvin.chk_kelvin.checked = lt.useColorTemperature
                CLM_Dialog.rol_extra.chk_shadows.checked = lt.castShadows
            ) catch()
        )
    )

    on rol_lights open do CLM_RefreshList()
)

-- ============================================================
-- 2-ROLLOUT: YOQISH / O'CHIRISH
-- ============================================================
rollout rol_onoff "Holat (Yoqish / O'chirish)" (

    button btn_on      "YOQISH"     width:135 height:30 across:3
    button btn_off     "O'CHIRISH"  width:135 height:30
    button btn_toggle  "TOGGLE"     width:135 height:30

    button btn_all_on  "BARCHASINI YOQISH"    width:210 height:28 across:2
    button btn_all_off "BARCHASINI O'CHIRISH"  width:210 height:28

    on btn_on pressed do (
        for lt in (CLM_GetSelectedFromList()) do lt.enabled = true
        CLM_RefreshList()
    )

    on btn_off pressed do (
        for lt in (CLM_GetSelectedFromList()) do lt.enabled = false
        CLM_RefreshList()
    )

    on btn_toggle pressed do (
        for lt in (CLM_GetSelectedFromList()) do lt.enabled = not lt.enabled
        CLM_RefreshList()
    )

    on btn_all_on pressed do (
        for lt in CLM_LightsList do lt.enabled = true
        CLM_RefreshList()
    )

    on btn_all_off pressed do (
        for lt in CLM_LightsList do lt.enabled = false
        CLM_RefreshList()
    )
)

-- ============================================================
-- 3-ROLLOUT: SOLO REJIM
-- ============================================================
rollout rol_solo "Solo Rejim" (

    label lbl_info "Faqat tanlangan chiroq(lar)ni yoqib qolganini o'chiradi" align:#left
    button btn_solo   "SOLO ON"   width:210 height:30 across:2
    button btn_unsolo "SOLO OFF (barchasini qaytarish)" width:210 height:30

    on btn_solo pressed do (
        local sel = CLM_GetSelectedFromList()
        if sel.count > 0 do (
            for lt in CLM_LightsList do lt.enabled = false
            for lt in sel do lt.enabled = true
            CLM_SoloedLight = sel
            CLM_RefreshList()
        )
    )

    on btn_unsolo pressed do (
        for lt in CLM_LightsList do lt.enabled = true
        CLM_SoloedLight = undefined
        CLM_RefreshList()
    )
)

-- ============================================================
-- 4-ROLLOUT: INTENSIVLIK
-- ============================================================
rollout rol_intensity "Intensivlik (Multiplier)" (

    spinner spn_intensity "Qiymati:" range:[0, 100000, 1000] type:#float scale:5 width:320
    button btn_apply   "Tanlanganlarga Qo'llash"  width:210 height:28 across:2
    button btn_apply_all "BARCHASIGA Qo'llash"    width:210 height:28

    -- Tezkor tugmalar
    label lbl_quick "Tezkor qiymatlar:" align:#left
    button btn_q1 "100"  width:65 height:24 across:6
    button btn_q2 "300"  width:65 height:24
    button btn_q3 "500"  width:65 height:24
    button btn_q4 "1000" width:65 height:24
    button btn_q5 "2000" width:65 height:24
    button btn_q6 "5000" width:65 height:24

    on btn_apply pressed do (
        for lt in (CLM_GetSelectedFromList()) do lt.intensity = spn_intensity.value
        CLM_RefreshList()
    )

    on btn_apply_all pressed do (
        for lt in CLM_LightsList do lt.intensity = spn_intensity.value
        CLM_RefreshList()
    )

    on btn_q1 pressed do (spn_intensity.value = 100;  btn_apply.pressed())
    on btn_q2 pressed do (spn_intensity.value = 300;  btn_apply.pressed())
    on btn_q3 pressed do (spn_intensity.value = 500;  btn_apply.pressed())
    on btn_q4 pressed do (spn_intensity.value = 1000; btn_apply.pressed())
    on btn_q5 pressed do (spn_intensity.value = 2000; btn_apply.pressed())
    on btn_q6 pressed do (spn_intensity.value = 5000; btn_apply.pressed())
)

-- ============================================================
-- 5-ROLLOUT: RANG
-- ============================================================
rollout rol_color "Chiroq Rangi" (

    colorpicker cp_color "Rang tanlash:" color:(color 255 238 200) width:250
    button btn_apply   "Tanlanganlarga Qo'llash" width:210 height:28 across:2
    button btn_apply_all "BARCHASIGA Qo'llash"   width:210 height:28

    -- Tezkor ranglar
    label lbl_quick "Tezkor ranglar:" align:#left
    button btn_warm   "Iliq oq"    width:100 height:24 across:4
    button btn_cold   "Sovuq oq"   width:100 height:24
    button btn_yellow "Sariq"      width:100 height:24
    button btn_day    "Kunduzi"    width:100 height:24

    on btn_apply pressed do (
        for lt in (CLM_GetSelectedFromList()) do (
            lt.color = cp_color.color
            lt.useColorTemperature = false
        )
        CLM_RefreshList()
    )

    on btn_apply_all pressed do (
        for lt in CLM_LightsList do (
            lt.color = cp_color.color
            lt.useColorTemperature = false
        )
        CLM_RefreshList()
    )

    on btn_warm   pressed do (cp_color.color = color 255 238 200; btn_apply.pressed())
    on btn_cold   pressed do (cp_color.color = color 200 220 255; btn_apply.pressed())
    on btn_yellow pressed do (cp_color.color = color 255 200 80;  btn_apply.pressed())
    on btn_day    pressed do (cp_color.color = color 255 255 250; btn_apply.pressed())
)

-- ============================================================
-- 6-ROLLOUT: KELVIN
-- ============================================================
rollout rol_kelvin "Rang Harorati (Kelvin)" (

    checkbox chk_kelvin "Kelvin rejimini yoqish" checked:false
    spinner spn_kelvin "Kelvin:" range:[1000, 15000, 4500] type:#integer scale:50 width:320
    button btn_apply   "Tanlanganlarga Qo'llash" width:210 height:28 across:2
    button btn_apply_all "BARCHASIGA Qo'llash"   width:210 height:28

    -- Tezkor kelvin
    label lbl_quick "Tezkor:" align:#left
    button btn_k1 "2700K Sham"   width:105 height:24 across:4
    button btn_k2 "4000K Neytr"  width:105 height:24
    button btn_k3 "5500K Kun"    width:105 height:24
    button btn_k4 "6500K Bulut"  width:105 height:24

    on btn_apply pressed do (
        for lt in (CLM_GetSelectedFromList()) do (
            lt.colorTemperature = spn_kelvin.value
            lt.useColorTemperature = true
        )
        chk_kelvin.checked = true
        CLM_RefreshList()
    )

    on btn_apply_all pressed do (
        for lt in CLM_LightsList do (
            lt.colorTemperature = spn_kelvin.value
            lt.useColorTemperature = true
        )
        chk_kelvin.checked = true
        CLM_RefreshList()
    )

    on chk_kelvin changed state do (
        for lt in (CLM_GetSelectedFromList()) do lt.useColorTemperature = state
    )

    on btn_k1 pressed do (spn_kelvin.value = 2700; btn_apply.pressed())
    on btn_k2 pressed do (spn_kelvin.value = 4000; btn_apply.pressed())
    on btn_k3 pressed do (spn_kelvin.value = 5500; btn_apply.pressed())
    on btn_k4 pressed do (spn_kelvin.value = 6500; btn_apply.pressed())
)

-- ============================================================
-- 7-ROLLOUT: O'LCHAM VA QO'SHIMCHA
-- ============================================================
rollout rol_extra "O'lcham va Qo'shimcha" (

    -- Size
    label lbl_size "Chiroq o'lchami (Size/Radius):" align:#left
    spinner spn_size "O'lcham:" range:[0, 5000, 50] type:#float scale:1 width:320
    button btn_apply_size "Tanlanganlarga Qo'llash" width:210 height:28 across:2
    button btn_size_all   "BARCHASIGA Qo'llash"     width:210 height:28

    label lbl_sep " " align:#left

    -- Shadows
    checkbox chk_shadows "Soyalar (Cast Shadows)" checked:true
    button btn_apply_shd "Soyalarni Qo'llash" width:210 height:28

    label lbl_sep2 " " align:#left

    -- Directionality
    label lbl_dir "Yo'nalish kuchi (Directionality):" align:#left
    spinner spn_dir "Qiymat:" range:[0, 1.0, 0.0] type:#float scale:0.05 width:320
    button btn_apply_dir "Qo'llash" width:210 height:28

    on btn_apply_size pressed do (
        for lt in (CLM_GetSelectedFromList()) do (
            try (lt.size = spn_size.value) catch()
            try (lt.width = spn_size.value; lt.length = spn_size.value) catch()
        )
    )

    on btn_size_all pressed do (
        for lt in CLM_LightsList do (
            try (lt.size = spn_size.value) catch()
            try (lt.width = spn_size.value; lt.length = spn_size.value) catch()
        )
    )

    on btn_apply_shd pressed do (
        for lt in (CLM_GetSelectedFromList()) do lt.castShadows = chk_shadows.checked
    )

    on btn_apply_dir pressed do (
        for lt in (CLM_GetSelectedFromList()) do (
            try (lt.directionality = spn_dir.value) catch()
        )
    )
)

-- ============================================================
-- 8-ROLLOUT: SAHNADA TANLASH
-- ============================================================
rollout rol_scene "Sahnada Tanlash" (

    button btn_select  "Sahnada Tanlash"   width:140 height:28 across:3
    button btn_focus   "Zoom to Selected"  width:140 height:28
    button btn_hide    "Boshqalarini Yashirish" width:140 height:28

    on btn_select pressed do (
        local sel = CLM_GetSelectedFromList()
        if sel.count > 0 do (
            select sel[1]
            for i = 2 to sel.count do selectMore sel[i]
        )
    )

    on btn_focus pressed do (
        local sel = CLM_GetSelectedFromList()
        if sel.count > 0 do (
            select sel[1]
            for i = 2 to sel.count do selectMore sel[i]
            max zoomext sel
        )
    )

    on btn_hide pressed do (
        local sel = CLM_GetSelectedFromList()
        for lt in CLM_LightsList do lt.isHidden = true
        for lt in sel do lt.isHidden = false
    )
)

-- ============================================================
-- ASOSIY DIALOG — SCROLLABLE SUBROLLOUT CONTAINER
-- ============================================================
rollout rol_main "Corona Light Manager Pro v3.0" width:470 height:600 (

    subrollout sub_container "Boshqaruv Paneli" \
        width:458 height:580 pos:[4,4]
)

-- ============================================================
-- OYNA OCHISH
-- ============================================================
if CLM_Dialog != undefined do (
    try (destroyDialog CLM_Dialog) catch()
    CLM_Dialog = undefined
)

createDialog rol_main \
    style:#(#style_titlebar, #style_border, #style_sysmenu, #style_resizing) \
    pos:[100,50]

CLM_Dialog = rol_main

-- SubRollout larga barcha bo'limlarni qo'shish
addSubRollout rol_main.sub_container rol_lights
addSubRollout rol_main.sub_container rol_onoff
addSubRollout rol_main.sub_container rol_solo
addSubRollout rol_main.sub_container rol_intensity
addSubRollout rol_main.sub_container rol_color
addSubRollout rol_main.sub_container rol_kelvin
addSubRollout rol_main.sub_container rol_extra
addSubRollout rol_main.sub_container rol_scene

) -- macroScript end
